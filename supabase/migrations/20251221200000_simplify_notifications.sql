-- Simplify Notification System
-- - Remove: weekly-spending-summaries, rate-app-reminders, daily-journal-prompts
-- - Modify: trip-reminders (4 trigger points), expense-reminders (2 PM UTC)
-- - Add: daily-tips (AI-generated, 8 AM UTC)

-- =============================================
-- 1. Unschedule Removed Jobs
-- =============================================

SELECT cron.unschedule('weekly-spending-summaries');
SELECT cron.unschedule('rate-app-reminders');
SELECT cron.unschedule('daily-journal-prompts');

-- =============================================
-- 2. Add daily_tips Column
-- =============================================

ALTER TABLE public.notification_settings
ADD COLUMN IF NOT EXISTS daily_tips BOOLEAN DEFAULT true;

-- =============================================
-- 3. Update Trip Reminders Function
-- New timing: 2 days before start, day of start, 2 days before end, day of end
-- =============================================

CREATE OR REPLACE FUNCTION public.send_trip_reminders()
RETURNS VOID AS $$
DECLARE
    v_trip RECORD;
    v_title TEXT;
    v_body TEXT;
    v_reminder_type TEXT;
BEGIN
    -- Find trips needing reminders at any of the 4 trigger points
    FOR v_trip IN
        SELECT
            t.id AS trip_id,
            t.title AS trip_title,
            t.destination,
            t.start_date,
            t.end_date,
            t.owner_id,
            CASE
                WHEN t.start_date = CURRENT_DATE + INTERVAL '2 days' THEN 'start_2_days'
                WHEN t.start_date = CURRENT_DATE THEN 'start_day'
                WHEN t.end_date = CURRENT_DATE + INTERVAL '2 days' THEN 'end_2_days'
                WHEN t.end_date = CURRENT_DATE THEN 'end_day'
            END AS reminder_type
        FROM trips t
        JOIN notification_settings ns ON ns.user_id = t.owner_id
        WHERE t.status IN ('planning', 'active')
          AND ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.trip_reminders = true
          AND t.start_date IS NOT NULL
          AND t.end_date IS NOT NULL
          AND (
              -- 2 days before start
              t.start_date = CURRENT_DATE + INTERVAL '2 days'
              -- Day of start
              OR t.start_date = CURRENT_DATE
              -- 2 days before end
              OR t.end_date = CURRENT_DATE + INTERVAL '2 days'
              -- Day of end
              OR t.end_date = CURRENT_DATE
          )
    LOOP
        v_reminder_type := v_trip.reminder_type;

        CASE v_reminder_type
            WHEN 'start_2_days' THEN
                v_title := 'Trip in 2 days! 🎒';
                v_body := format('Your trip "%s" to %s starts in 2 days. Time to prepare!',
                               v_trip.trip_title, v_trip.destination);
            WHEN 'start_day' THEN
                v_title := 'Your trip starts today! ✈️';
                v_body := format('Your trip "%s" to %s begins today. Have a great time!',
                               v_trip.trip_title, v_trip.destination);
            WHEN 'end_2_days' THEN
                v_title := 'Trip ending soon 📅';
                v_body := format('Your trip "%s" ends in 2 days. Make the most of it!',
                               v_trip.trip_title);
            WHEN 'end_day' THEN
                v_title := 'Last day of your trip! 🌟';
                v_body := format('Today is the last day of "%s". Safe travels home!',
                               v_trip.trip_title);
            ELSE
                CONTINUE;
        END CASE;

        PERFORM public.send_push_notification(
            v_trip.owner_id,
            v_title,
            v_body,
            'trip_reminder',
            jsonb_build_object('id', v_trip.trip_id::text)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- =============================================
-- 4. Update Expense Reminders Function
-- Now runs once at 2 PM UTC (no user-configured time)
-- =============================================

CREATE OR REPLACE FUNCTION public.send_expense_reminders()
RETURNS VOID AS $$
DECLARE
    v_trip RECORD;
    v_has_expense_today BOOLEAN;
BEGIN
    -- Find active trips where user hasn't logged expense today
    FOR v_trip IN
        SELECT
            t.id AS trip_id,
            t.title AS trip_title,
            t.owner_id
        FROM trips t
        JOIN notification_settings ns ON ns.user_id = t.owner_id
        WHERE t.status = 'active'
          AND ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.expense_reminder = true
    LOOP
        -- Check if expense logged today
        SELECT EXISTS(
            SELECT 1 FROM expenses
            WHERE trip_id = v_trip.trip_id
              AND expense_date = CURRENT_DATE
        ) INTO v_has_expense_today;

        -- Only remind if no expense logged today
        IF NOT v_has_expense_today THEN
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
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- =============================================
-- 5. Create Daily Tips Function (AI-Generated)
-- =============================================

CREATE OR REPLACE FUNCTION public.send_daily_tips()
RETURNS VOID AS $$
DECLARE
    v_user RECORD;
    v_supabase_url TEXT;
    v_service_key TEXT;
    v_response JSONB;
BEGIN
    -- Get Supabase URL from vault
    SELECT decrypted_secret INTO v_supabase_url
    FROM vault.decrypted_secrets
    WHERE name = 'supabase_url';

    SELECT decrypted_secret INTO v_service_key
    FROM vault.decrypted_secrets
    WHERE name = 'service_role_key';

    -- Fallback to settings if vault not configured
    IF v_supabase_url IS NULL THEN
        v_supabase_url := current_setting('app.settings.supabase_url', true);
    END IF;
    IF v_service_key IS NULL THEN
        v_service_key := current_setting('app.settings.service_role_key', true);
    END IF;

    -- Find users with daily tips enabled
    FOR v_user IN
        SELECT
            ns.user_id,
            (
                SELECT jsonb_agg(jsonb_build_object(
                    'destination', t.destination,
                    'start_date', t.start_date,
                    'end_date', t.end_date,
                    'status', t.status
                ))
                FROM trips t
                WHERE t.owner_id = ns.user_id
                  AND t.status IN ('planning', 'active')
                  AND t.start_date >= CURRENT_DATE - INTERVAL '7 days'
                LIMIT 3
            ) AS upcoming_trips
        FROM notification_settings ns
        WHERE ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.daily_tips = true
    LOOP
        -- Call edge function to generate and send tip
        PERFORM net.http_post(
            url := v_supabase_url || '/functions/v1/generate-daily-tip',
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || v_service_key
            ),
            body := jsonb_build_object(
                'user_id', v_user.user_id,
                'upcoming_trips', COALESCE(v_user.upcoming_trips, '[]'::jsonb)
            )
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public';

-- =============================================
-- 6. Update Cron Schedules
-- =============================================

-- Reschedule expense reminders to 2 PM UTC (once daily)
SELECT cron.unschedule('expense-reminders');
SELECT cron.schedule(
    'expense-reminders',
    '0 14 * * *',
    $$SELECT public.send_expense_reminders()$$
);

-- Schedule daily tips at 8 AM UTC
SELECT cron.schedule(
    'daily-tips',
    '0 8 * * *',
    $$SELECT public.send_daily_tips()$$
);

-- =============================================
-- 7. Grant Permissions
-- =============================================

GRANT EXECUTE ON FUNCTION public.send_daily_tips TO service_role;

-- =============================================
-- 8. Drop Unused Functions (optional cleanup)
-- =============================================

-- Keep functions for now in case they're needed, just remove cron jobs
-- DROP FUNCTION IF EXISTS public.send_weekly_spending_summaries();
-- DROP FUNCTION IF EXISTS public.send_rate_app_reminders();
-- DROP FUNCTION IF EXISTS public.send_daily_journal_prompts();
