-- Support Email Notifications
-- Triggers to send email notifications for support-related events

-- =============================================
-- 1. Helper function to call the email notification edge function
-- =============================================

CREATE OR REPLACE FUNCTION public.send_support_email(
    p_user_id UUID,
    p_type TEXT,
    p_session_id UUID,
    p_subject TEXT DEFAULT NULL,
    p_message TEXT DEFAULT NULL,
    p_new_status TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_supabase_url TEXT;
    v_service_key TEXT;
BEGIN
    -- Get Supabase URL from settings
    SELECT decrypted_secret INTO v_supabase_url
    FROM vault.decrypted_secrets
    WHERE name = 'supabase_url';

    SELECT decrypted_secret INTO v_service_key
    FROM vault.decrypted_secrets
    WHERE name = 'service_role_key';

    -- Fallback to environment approach
    IF v_supabase_url IS NULL THEN
        v_supabase_url := current_setting('app.settings.supabase_url', true);
    END IF;

    IF v_service_key IS NULL THEN
        v_service_key := current_setting('app.settings.service_role_key', true);
    END IF;

    -- Skip if URLs not configured
    IF v_supabase_url IS NULL OR v_service_key IS NULL THEN
        RAISE NOTICE 'Supabase URL or service key not configured for email notifications';
        RETURN;
    END IF;

    -- Call the edge function using pg_net
    PERFORM net.http_post(
        url := v_supabase_url || '/functions/v1/send-support-email',
        headers := jsonb_build_object(
            'Content-Type', 'application/json',
            'Authorization', 'Bearer ' || v_service_key
        ),
        body := jsonb_build_object(
            'user_id', p_user_id,
            'type', p_type,
            'session_id', p_session_id,
            'subject', p_subject,
            'message', p_message,
            'new_status', p_new_status
        )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 2. Email notification for support reply
-- =============================================

CREATE OR REPLACE FUNCTION public.email_notify_support_reply()
RETURNS TRIGGER AS $$
DECLARE
    v_session RECORD;
BEGIN
    -- Only notify on admin messages
    IF NEW.sender_role != 'admin' THEN
        RETURN NEW;
    END IF;

    -- Get session details and check if email notifications are enabled
    SELECT
        ss.id AS session_id,
        ss.user_id,
        ss.subject,
        ns.master_enabled,
        ns.email_notifications,
        ns.support_reply_notifications
    INTO v_session
    FROM support_sessions ss
    LEFT JOIN notification_settings ns ON ns.user_id = ss.user_id
    WHERE ss.id = NEW.session_id;

    -- Check if email notifications are enabled
    IF v_session IS NOT NULL
       AND (v_session.master_enabled IS NULL OR v_session.master_enabled)
       AND (v_session.email_notifications IS NULL OR v_session.email_notifications)
       AND (v_session.support_reply_notifications IS NULL OR v_session.support_reply_notifications) THEN

        PERFORM public.send_support_email(
            v_session.user_id,
            'support_reply',
            v_session.session_id,
            v_session.subject,
            LEFT(NEW.content, 500)  -- Truncate long messages
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_email_support_reply ON public.support_messages;
CREATE TRIGGER trigger_email_support_reply
    AFTER INSERT ON public.support_messages
    FOR EACH ROW
    EXECUTE FUNCTION public.email_notify_support_reply();

-- =============================================
-- 3. Email notification for ticket status changes
-- =============================================

CREATE OR REPLACE FUNCTION public.email_notify_ticket_status_change()
RETURNS TRIGGER AS $$
DECLARE
    v_settings RECORD;
    v_email_type TEXT;
BEGIN
    -- Only notify on status changes
    IF OLD.status = NEW.status THEN
        RETURN NEW;
    END IF;

    -- Get notification settings
    SELECT
        ns.master_enabled,
        ns.email_notifications,
        ns.ticket_status_updates
    INTO v_settings
    FROM notification_settings ns
    WHERE ns.user_id = NEW.user_id;

    -- Check if email notifications are enabled
    IF v_settings IS NOT NULL
       AND NOT v_settings.master_enabled THEN
        RETURN NEW;
    END IF;

    IF v_settings IS NOT NULL
       AND NOT v_settings.email_notifications THEN
        RETURN NEW;
    END IF;

    IF v_settings IS NOT NULL
       AND NOT v_settings.ticket_status_updates THEN
        RETURN NEW;
    END IF;

    -- Determine email type based on new status
    IF NEW.status = 'resolved' THEN
        v_email_type := 'ticket_resolved';
    ELSE
        v_email_type := 'ticket_status_changed';
    END IF;

    PERFORM public.send_support_email(
        NEW.user_id,
        v_email_type,
        NEW.id,
        NEW.subject,
        NULL,
        NEW.status
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_email_ticket_status_change ON public.support_sessions;
CREATE TRIGGER trigger_email_ticket_status_change
    AFTER UPDATE ON public.support_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.email_notify_ticket_status_change();

-- =============================================
-- 4. Email notification for new ticket created
-- =============================================

CREATE OR REPLACE FUNCTION public.email_notify_ticket_created()
RETURNS TRIGGER AS $$
DECLARE
    v_settings RECORD;
BEGIN
    -- Get notification settings
    SELECT
        ns.master_enabled,
        ns.email_notifications
    INTO v_settings
    FROM notification_settings ns
    WHERE ns.user_id = NEW.user_id;

    -- Check if email notifications are enabled (default to true if no settings)
    IF v_settings IS NOT NULL
       AND (NOT v_settings.master_enabled OR NOT v_settings.email_notifications) THEN
        RETURN NEW;
    END IF;

    PERFORM public.send_support_email(
        NEW.user_id,
        'ticket_created',
        NEW.id,
        NEW.subject
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_email_ticket_created ON public.support_sessions;
CREATE TRIGGER trigger_email_ticket_created
    AFTER INSERT ON public.support_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.email_notify_ticket_created();

-- =============================================
-- 5. Grant permissions
-- =============================================

GRANT EXECUTE ON FUNCTION public.send_support_email TO service_role;
GRANT EXECUTE ON FUNCTION public.email_notify_support_reply TO service_role;
GRANT EXECUTE ON FUNCTION public.email_notify_ticket_status_change TO service_role;
GRANT EXECUTE ON FUNCTION public.email_notify_ticket_created TO service_role;

-- =============================================
-- 6. Add fcm_token columns to profiles if not exists
-- =============================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                   AND table_name = 'profiles'
                   AND column_name = 'fcm_token') THEN
        ALTER TABLE public.profiles ADD COLUMN fcm_token TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_schema = 'public'
                   AND table_name = 'profiles'
                   AND column_name = 'fcm_token_updated_at') THEN
        ALTER TABLE public.profiles ADD COLUMN fcm_token_updated_at TIMESTAMPTZ;
    END IF;
END $$;

-- Index for efficient FCM token lookups
CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token ON public.profiles(fcm_token) WHERE fcm_token IS NOT NULL;
