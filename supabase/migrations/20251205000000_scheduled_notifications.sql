-- Phase 7: Scheduled Notifications using pg_cron
-- Prerequisites: Enable pg_cron and pg_net extensions in Supabase Dashboard → Database → Extensions

-- =============================================
-- 1. Helper function to call the push notification edge function
-- =============================================

CREATE OR REPLACE FUNCTION public.send_push_notification(
    p_user_id UUID,
    p_title TEXT,
    p_body TEXT,
    p_type TEXT,
    p_data JSONB DEFAULT '{}'
)
RETURNS VOID AS $$
DECLARE
    v_supabase_url TEXT;
    v_service_key TEXT;
BEGIN
    -- Get Supabase URL from settings (set by dashboard)
    SELECT decrypted_secret INTO v_supabase_url
    FROM vault.decrypted_secrets
    WHERE name = 'supabase_url';

    SELECT decrypted_secret INTO v_service_key
    FROM vault.decrypted_secrets
    WHERE name = 'service_role_key';

    -- If vault is not set up, use environment approach
    IF v_supabase_url IS NULL THEN
        v_supabase_url := current_setting('app.settings.supabase_url', true);
    END IF;

    IF v_service_key IS NULL THEN
        v_service_key := current_setting('app.settings.service_role_key', true);
    END IF;

    -- Call the edge function using pg_net
    PERFORM net.http_post(
        url := v_supabase_url || '/functions/v1/send-push-notification',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || v_service_key
        ),
        body := jsonb_build_object(
            'user_id', p_user_id,
            'title', p_title,
            'body', p_body,
            'type', p_type,
            'data', p_data
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 2. Trip Reminders Function
-- Sends reminders X days before trip start date
-- =============================================

CREATE OR REPLACE FUNCTION public.send_trip_reminders()
RETURNS VOID AS $$
DECLARE
    v_trip RECORD;
    v_days_until INTEGER;
    v_title TEXT;
    v_body TEXT;
BEGIN
    -- Find trips with upcoming start dates
    FOR v_trip IN
        SELECT
            t.id AS trip_id,
            t.title AS trip_title,
            t.destination,
            t.start_date,
            t.owner_id,
            ns.trip_reminders,
            ns.trip_reminder_days_before
        FROM trips t
        JOIN notification_settings ns ON ns.user_id = t.owner_id
        WHERE t.status = 'planning'
          AND t.start_date IS NOT NULL
          AND ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.trip_reminders = true
          AND t.start_date >= CURRENT_DATE
          AND t.start_date <= CURRENT_DATE + ns.trip_reminder_days_before
    LOOP
        v_days_until := v_trip.start_date - CURRENT_DATE;

        IF v_days_until = 0 THEN
            v_title := 'Your trip starts today! ✈️';
            v_body := format('Your trip "%s" to %s begins today. Have a great time!',
                           v_trip.trip_title, v_trip.destination);
        ELSIF v_days_until = 1 THEN
            v_title := 'Trip tomorrow! 🎒';
            v_body := format('Your trip "%s" to %s starts tomorrow. Are you ready?',
                           v_trip.trip_title, v_trip.destination);
        ELSE
            v_title := format('Trip in %s days', v_days_until);
            v_body := format('Your trip "%s" to %s is coming up. Time to prepare!',
                           v_trip.trip_title, v_trip.destination);
        END IF;

        PERFORM public.send_push_notification(
            v_trip.owner_id,
            v_title,
            v_body,
            'trip_reminder',
            jsonb_build_object('id', v_trip.trip_id::text)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 3. Daily Trip Summary Function
-- Sends daily summary at user-configured time during active trips
-- =============================================

CREATE OR REPLACE FUNCTION public.send_daily_trip_summaries()
RETURNS VOID AS $$
DECLARE
    v_trip RECORD;
    v_expense_total DECIMAL;
    v_expense_count INTEGER;
BEGIN
    -- Find active trips where it's time for daily summary
    FOR v_trip IN
        SELECT
            t.id AS trip_id,
            t.title AS trip_title,
            t.destination,
            t.owner_id,
            t.budget,
            t.budget_currency,
            ns.daily_trip_summary_time
        FROM trips t
        JOIN notification_settings ns ON ns.user_id = t.owner_id
        WHERE t.status = 'active'
          AND ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.daily_trip_summary = true
          -- Check if current hour matches user's configured time (UTC)
          AND EXTRACT(HOUR FROM NOW() AT TIME ZONE 'UTC') = EXTRACT(HOUR FROM ns.daily_trip_summary_time)
    LOOP
        -- Calculate today's expenses
        SELECT COALESCE(SUM(amount), 0), COUNT(*)
        INTO v_expense_total, v_expense_count
        FROM expenses
        WHERE trip_id = v_trip.trip_id
          AND expense_date = CURRENT_DATE;

        PERFORM public.send_push_notification(
            v_trip.owner_id,
            format('%s - Daily Summary', v_trip.trip_title),
            format('Today in %s: %s expenses totaling %s %s',
                   v_trip.destination,
                   v_expense_count,
                   v_expense_total,
                   v_trip.budget_currency),
            'daily_summary',
            jsonb_build_object('id', v_trip.trip_id::text)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 4. Expense Reminder Function
-- Reminds users to log expenses during active trips
-- =============================================

CREATE OR REPLACE FUNCTION public.send_expense_reminders()
RETURNS VOID AS $$
DECLARE
    v_trip RECORD;
    v_last_expense_date DATE;
BEGIN
    -- Find active trips where it's time for expense reminder
    FOR v_trip IN
        SELECT
            t.id AS trip_id,
            t.title AS trip_title,
            t.owner_id,
            ns.expense_reminder_time
        FROM trips t
        JOIN notification_settings ns ON ns.user_id = t.owner_id
        WHERE t.status = 'active'
          AND ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.expense_reminder = true
          -- Check if current hour matches user's configured time
          AND EXTRACT(HOUR FROM NOW() AT TIME ZONE 'UTC') = EXTRACT(HOUR FROM ns.expense_reminder_time)
    LOOP
        -- Check when the last expense was logged
        SELECT MAX(expense_date) INTO v_last_expense_date
        FROM expenses
        WHERE trip_id = v_trip.trip_id;

        -- Only remind if no expense logged today
        IF v_last_expense_date IS NULL OR v_last_expense_date < CURRENT_DATE THEN
            PERFORM public.send_push_notification(
                v_trip.owner_id,
                'Don''t forget your expenses! 💰',
                format('Track your spending for "%s" to stay on budget.', v_trip.trip_title),
                'expense_reminder',
                jsonb_build_object('id', v_trip.trip_id::text)
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 5. Daily Journal Prompt Function
-- Prompts users to write in their journal during active trips
-- =============================================

CREATE OR REPLACE FUNCTION public.send_daily_journal_prompts()
RETURNS VOID AS $$
DECLARE
    v_trip RECORD;
    v_has_entry_today BOOLEAN;
BEGIN
    -- Find active trips where it's time for journal prompt
    FOR v_trip IN
        SELECT
            t.id AS trip_id,
            t.title AS trip_title,
            t.destination,
            t.owner_id,
            ns.daily_journal_time
        FROM trips t
        JOIN notification_settings ns ON ns.user_id = t.owner_id
        WHERE t.status = 'active'
          AND ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.daily_journal_prompt = true
          -- Check if current hour matches user's configured time
          AND EXTRACT(HOUR FROM NOW() AT TIME ZONE 'UTC') = EXTRACT(HOUR FROM ns.daily_journal_time)
    LOOP
        -- Check if user already wrote a journal entry today
        SELECT EXISTS(
            SELECT 1 FROM journal_entries
            WHERE trip_id = v_trip.trip_id
              AND DATE(created_at) = CURRENT_DATE
        ) INTO v_has_entry_today;

        -- Only prompt if no entry today
        IF NOT v_has_entry_today THEN
            PERFORM public.send_push_notification(
                v_trip.owner_id,
                'Capture today''s memories! 📝',
                format('What happened today in %s? Add it to your journal.', v_trip.destination),
                'journal_prompt',
                jsonb_build_object('id', v_trip.trip_id::text)
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 6. Weekly Spending Summary Function
-- Sends aggregate weekly expense summary on Sundays
-- =============================================

CREATE OR REPLACE FUNCTION public.send_weekly_spending_summaries()
RETURNS VOID AS $$
DECLARE
    v_user RECORD;
    v_total_spent DECIMAL;
    v_trip_count INTEGER;
BEGIN
    -- Only run on Sundays
    IF EXTRACT(DOW FROM NOW()) != 0 THEN
        RETURN;
    END IF;

    -- Find users with weekly summary enabled
    FOR v_user IN
        SELECT
            ns.user_id,
            p.preferred_currency
        FROM notification_settings ns
        JOIN profiles p ON p.id = ns.user_id
        WHERE ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.weekly_spending_summary = true
    LOOP
        -- Calculate week's expenses across all trips
        SELECT COALESCE(SUM(e.amount), 0), COUNT(DISTINCT e.trip_id)
        INTO v_total_spent, v_trip_count
        FROM expenses e
        JOIN trips t ON t.id = e.trip_id
        WHERE t.owner_id = v_user.user_id
          AND e.expense_date >= CURRENT_DATE - INTERVAL '7 days';

        -- Only send if there were expenses
        IF v_total_spent > 0 THEN
            PERFORM public.send_push_notification(
                v_user.user_id,
                'Weekly Spending Summary 📊',
                format('This week: %s %s across %s trip(s).',
                       v_total_spent,
                       COALESCE(v_user.preferred_currency, 'USD'),
                       v_trip_count),
                'weekly_spending',
                '{}'::jsonb
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 7. Rate App Reminder Function
-- Prompts users to rate the app 7 days after signup
-- =============================================

CREATE OR REPLACE FUNCTION public.send_rate_app_reminders()
RETURNS VOID AS $$
DECLARE
    v_user RECORD;
BEGIN
    -- Find users who signed up 7 days ago and have rate_app_reminder enabled
    FOR v_user IN
        SELECT
            p.id AS user_id
        FROM profiles p
        JOIN notification_settings ns ON ns.user_id = p.id
        WHERE ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.rate_app_reminder = true
          AND DATE(p.created_at) = CURRENT_DATE - INTERVAL '7 days'
    LOOP
        PERFORM public.send_push_notification(
            v_user.user_id,
            'Enjoying Waylo? ⭐',
            'Help us improve by rating the app. Your feedback matters!',
            'rate_app',
            '{}'::jsonb
        );

        -- Disable further rate app reminders for this user
        UPDATE notification_settings
        SET rate_app_reminder = false
        WHERE user_id = v_user.user_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 8. Cron Job Definitions (requires pg_cron extension)
-- Run these manually or uncomment after enabling pg_cron
-- =============================================

-- NOTE: These cron jobs require pg_cron extension to be enabled.
-- Enable it in Supabase Dashboard → Database → Extensions → pg_cron
-- Then run these commands:

/*
-- Trip reminders: Daily at 9 AM UTC
SELECT cron.schedule(
    'trip-reminders',
    '0 9 * * *',
    $$SELECT public.send_trip_reminders()$$
);

-- Daily trip summaries: Every hour (checks user's configured time)
SELECT cron.schedule(
    'daily-trip-summaries',
    '0 * * * *',
    $$SELECT public.send_daily_trip_summaries()$$
);

-- Expense reminders: Every hour (checks user's configured time)
SELECT cron.schedule(
    'expense-reminders',
    '0 * * * *',
    $$SELECT public.send_expense_reminders()$$
);

-- Daily journal prompts: Every hour (checks user's configured time)
SELECT cron.schedule(
    'daily-journal-prompts',
    '0 * * * *',
    $$SELECT public.send_daily_journal_prompts()$$
);

-- Weekly spending summary: Sundays at 10 AM UTC
SELECT cron.schedule(
    'weekly-spending-summaries',
    '0 10 * * 0',
    $$SELECT public.send_weekly_spending_summaries()$$
);

-- Rate app reminders: Daily at 12 PM UTC
SELECT cron.schedule(
    'rate-app-reminders',
    '0 12 * * *',
    $$SELECT public.send_rate_app_reminders()$$
);
*/

-- =============================================
-- 9. Grant permissions
-- =============================================

GRANT EXECUTE ON FUNCTION public.send_push_notification TO service_role;
GRANT EXECUTE ON FUNCTION public.send_trip_reminders TO service_role;
GRANT EXECUTE ON FUNCTION public.send_daily_trip_summaries TO service_role;
GRANT EXECUTE ON FUNCTION public.send_expense_reminders TO service_role;
GRANT EXECUTE ON FUNCTION public.send_daily_journal_prompts TO service_role;
GRANT EXECUTE ON FUNCTION public.send_weekly_spending_summaries TO service_role;
GRANT EXECUTE ON FUNCTION public.send_rate_app_reminders TO service_role;
