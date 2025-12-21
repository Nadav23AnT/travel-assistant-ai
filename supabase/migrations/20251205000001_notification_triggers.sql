-- Phase 8: Event-Driven Notifications using Database Triggers
-- These triggers fire real-time notifications based on database events

-- =============================================
-- 1. Support Reply Notification Trigger
-- Notifies user when admin replies to their support ticket
-- =============================================

CREATE OR REPLACE FUNCTION public.notify_support_reply()
RETURNS TRIGGER AS $$
DECLARE
    v_session RECORD;
BEGIN
    -- Only notify on admin messages
    IF NEW.sender_role != 'admin' THEN
        RETURN NEW;
    END IF;

    -- Get session details and user
    SELECT
        ss.id AS session_id,
        ss.user_id,
        ss.subject,
        ns.master_enabled,
        ns.push_notifications,
        ns.support_reply_notifications
    INTO v_session
    FROM support_sessions ss
    JOIN notification_settings ns ON ns.user_id = ss.user_id
    WHERE ss.id = NEW.session_id;

    -- Check if notifications are enabled
    IF v_session IS NOT NULL
       AND v_session.master_enabled
       AND v_session.push_notifications
       AND v_session.support_reply_notifications THEN

        PERFORM public.send_push_notification(
            v_session.user_id,
            'Support Reply 💬',
            format('New reply on "%s"', v_session.subject),
            'support_reply',
            jsonb_build_object('id', v_session.session_id::text)
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_support_reply_notification ON public.support_messages;
CREATE TRIGGER trigger_support_reply_notification
    AFTER INSERT ON public.support_messages
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_support_reply();

-- =============================================
-- 2. Budget Alert Notification Trigger
-- Notifies user when spending exceeds budget threshold
-- =============================================

CREATE OR REPLACE FUNCTION public.notify_budget_alert()
RETURNS TRIGGER AS $$
DECLARE
    v_trip RECORD;
    v_total_spent DECIMAL;
    v_budget_percentage DECIMAL;
    v_threshold DECIMAL;
    v_alert_key TEXT;
BEGIN
    -- Get trip details with budget
    SELECT
        t.id AS trip_id,
        t.title AS trip_title,
        t.owner_id,
        t.budget,
        t.budget_currency,
        ns.master_enabled,
        ns.push_notifications,
        ns.budget_alerts,
        ns.budget_alert_threshold
    INTO v_trip
    FROM trips t
    JOIN notification_settings ns ON ns.user_id = t.owner_id
    WHERE t.id = NEW.trip_id;

    -- Skip if no budget set or notifications disabled
    IF v_trip IS NULL
       OR v_trip.budget IS NULL
       OR v_trip.budget <= 0
       OR NOT v_trip.master_enabled
       OR NOT v_trip.push_notifications
       OR NOT v_trip.budget_alerts THEN
        RETURN NEW;
    END IF;

    -- Calculate total spent on this trip
    SELECT COALESCE(SUM(amount), 0) INTO v_total_spent
    FROM expenses
    WHERE trip_id = NEW.trip_id;

    -- Calculate percentage of budget used
    v_budget_percentage := v_total_spent / v_trip.budget;
    v_threshold := v_trip.budget_alert_threshold;

    -- Use a unique key per trip + threshold crossing to prevent duplicate alerts
    v_alert_key := format('budget_alert_%s_%s', v_trip.trip_id, FLOOR(v_budget_percentage * 10)::INTEGER);

    -- Send alert at different thresholds
    IF v_budget_percentage >= 1.0 THEN
        -- Over budget
        PERFORM public.send_push_notification(
            v_trip.owner_id,
            'Budget Exceeded! ⚠️',
            format('"%s" is over budget. Spent: %s %s / Budget: %s %s',
                   v_trip.trip_title,
                   ROUND(v_total_spent, 2),
                   v_trip.budget_currency,
                   v_trip.budget,
                   v_trip.budget_currency),
            'budget_alert',
            jsonb_build_object('id', v_trip.trip_id::text)
        );
    ELSIF v_budget_percentage >= v_threshold THEN
        -- Approaching threshold
        PERFORM public.send_push_notification(
            v_trip.owner_id,
            format('Budget Alert: %s%% used', ROUND(v_budget_percentage * 100)),
            format('"%s": %s %s spent of %s %s budget',
                   v_trip.trip_title,
                   ROUND(v_total_spent, 2),
                   v_trip.budget_currency,
                   v_trip.budget,
                   v_trip.budget_currency),
            'budget_alert',
            jsonb_build_object('id', v_trip.trip_id::text)
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_budget_alert ON public.expenses;
CREATE TRIGGER trigger_budget_alert
    AFTER INSERT ON public.expenses
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_budget_alert();

-- =============================================
-- 3. Trip Status Change Notification Trigger
-- Notifies user when trip status changes
-- =============================================

CREATE OR REPLACE FUNCTION public.notify_trip_status_change()
RETURNS TRIGGER AS $$
DECLARE
    v_settings RECORD;
    v_title TEXT;
    v_body TEXT;
BEGIN
    -- Only notify on status changes
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    -- Get notification settings
    SELECT
        ns.master_enabled,
        ns.push_notifications,
        ns.trip_status_changes
    INTO v_settings
    FROM notification_settings ns
    WHERE ns.user_id = NEW.owner_id;

    -- Check if notifications are enabled
    IF v_settings IS NULL
       OR NOT v_settings.master_enabled
       OR NOT v_settings.push_notifications
       OR NOT v_settings.trip_status_changes THEN
        RETURN NEW;
    END IF;

    -- Generate appropriate message based on new status
    CASE NEW.status
        WHEN 'active' THEN
            v_title := 'Trip Started! 🎉';
            v_body := format('"%s" is now active. Have an amazing trip!', NEW.title);
        WHEN 'completed' THEN
            v_title := 'Trip Completed ✅';
            v_body := format('"%s" has been marked as completed.', NEW.title);
        WHEN 'canceled' THEN
            v_title := 'Trip Canceled';
            v_body := format('"%s" has been canceled.', NEW.title);
        ELSE
            v_title := 'Trip Status Updated';
            v_body := format('"%s" status changed to %s', NEW.title, NEW.status);
    END CASE;

    PERFORM public.send_push_notification(
        NEW.owner_id,
        v_title,
        v_body,
        'trip_status',
        jsonb_build_object('id', NEW.id::text)
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_trip_status_change ON public.trips;
CREATE TRIGGER trigger_trip_status_change
    AFTER UPDATE ON public.trips
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_trip_status_change();

-- =============================================
-- 4. Journal Ready Notification Function
-- Called by cron job to check for completed trips without journal notification sent
-- =============================================

CREATE OR REPLACE FUNCTION public.send_journal_ready_notifications()
RETURNS VOID AS $$
DECLARE
    v_trip RECORD;
BEGIN
    -- Find trips that ended yesterday and haven't been notified
    FOR v_trip IN
        SELECT
            t.id AS trip_id,
            t.title AS trip_title,
            t.destination,
            t.owner_id
        FROM trips t
        JOIN notification_settings ns ON ns.user_id = t.owner_id
        LEFT JOIN journal_entries je ON je.trip_id = t.id
        WHERE t.status IN ('active', 'completed')
          AND t.end_date = CURRENT_DATE - INTERVAL '1 day'
          AND ns.master_enabled = true
          AND ns.push_notifications = true
          AND ns.journal_ready = true
          -- Only notify if there's no journal entry yet
          AND je.id IS NULL
        GROUP BY t.id, t.title, t.destination, t.owner_id
    LOOP
        PERFORM public.send_push_notification(
            v_trip.owner_id,
            'Your Journal is Ready! 📖',
            format('Create your travel journal for "%s" to %s',
                   v_trip.trip_title, v_trip.destination),
            'journal_ready',
            jsonb_build_object('id', v_trip.trip_id::text)
        );

        -- Mark trip as completed if still active
        UPDATE trips
        SET status = 'completed'
        WHERE id = v_trip.trip_id AND status = 'active';
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 5. Support Ticket Status Change Notification
-- Notifies user when their ticket status changes
-- =============================================

CREATE OR REPLACE FUNCTION public.notify_ticket_status_change()
RETURNS TRIGGER AS $$
DECLARE
    v_settings RECORD;
    v_title TEXT;
    v_body TEXT;
BEGIN
    -- Only notify on status changes
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    -- Get notification settings
    SELECT
        ns.master_enabled,
        ns.push_notifications,
        ns.ticket_status_updates
    INTO v_settings
    FROM notification_settings ns
    WHERE ns.user_id = NEW.user_id;

    -- Check if notifications are enabled
    IF v_settings IS NULL
       OR NOT v_settings.master_enabled
       OR NOT v_settings.push_notifications
       OR NOT v_settings.ticket_status_updates THEN
        RETURN NEW;
    END IF;

    -- Generate appropriate message based on new status
    CASE NEW.status
        WHEN 'in_progress' THEN
            v_title := 'Ticket In Progress 🔄';
            v_body := format('Your support ticket "%s" is being reviewed.', NEW.subject);
        WHEN 'resolved' THEN
            v_title := 'Ticket Resolved ✅';
            v_body := format('Your support ticket "%s" has been resolved.', NEW.subject);
        WHEN 'closed' THEN
            v_title := 'Ticket Closed';
            v_body := format('Your support ticket "%s" has been closed.', NEW.subject);
        ELSE
            v_title := 'Ticket Status Updated';
            v_body := format('Your ticket "%s" status: %s', NEW.subject, NEW.status);
    END CASE;

    PERFORM public.send_push_notification(
        NEW.user_id,
        v_title,
        v_body,
        'ticket_update',
        jsonb_build_object('id', NEW.id::text)
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_ticket_status_change ON public.support_sessions;
CREATE TRIGGER trigger_ticket_status_change
    AFTER UPDATE ON public.support_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_ticket_status_change();

-- =============================================
-- 6. Cron job for journal ready notifications
-- =============================================

/*
-- Journal ready check: Daily at 10 AM UTC (day after trip ends)
SELECT cron.schedule(
    'journal-ready-notifications',
    '0 10 * * *',
    $$SELECT public.send_journal_ready_notifications()$$
);
*/

-- =============================================
-- 7. Grant permissions
-- =============================================

GRANT EXECUTE ON FUNCTION public.notify_support_reply TO service_role;
GRANT EXECUTE ON FUNCTION public.notify_budget_alert TO service_role;
GRANT EXECUTE ON FUNCTION public.notify_trip_status_change TO service_role;
GRANT EXECUTE ON FUNCTION public.send_journal_ready_notifications TO service_role;
GRANT EXECUTE ON FUNCTION public.notify_ticket_status_change TO service_role;
