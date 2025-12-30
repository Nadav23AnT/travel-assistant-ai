-- =====================================================
-- Notification Lifetime Feature
-- =====================================================
-- Adds configurable auto-dismiss hours for notifications
-- Default: 48 hours (instead of hardcoded 7 days)
-- =====================================================

-- Add auto_dismiss_hours column
ALTER TABLE public.admin_notifications
ADD COLUMN IF NOT EXISTS auto_dismiss_hours INTEGER DEFAULT 48
    CHECK (auto_dismiss_hours >= 1 AND auto_dismiss_hours <= 720);

COMMENT ON COLUMN public.admin_notifications.auto_dismiss_hours IS
    'Hours until notification auto-dismisses (1-720, default 48)';

-- Create trigger function to calculate expires_at from auto_dismiss_hours
CREATE OR REPLACE FUNCTION public.calculate_notification_expiry()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate expires_at based on auto_dismiss_hours
    NEW.expires_at := NEW.sent_at + (NEW.auto_dismiss_hours || ' hours')::INTERVAL;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for insert and update
DROP TRIGGER IF EXISTS set_notification_expiry ON public.admin_notifications;
CREATE TRIGGER set_notification_expiry
    BEFORE INSERT OR UPDATE OF auto_dismiss_hours, sent_at ON public.admin_notifications
    FOR EACH ROW
    EXECUTE FUNCTION public.calculate_notification_expiry();

-- Update existing notifications to have auto_dismiss_hours calculated from expires_at
-- (Preserve existing expiry behavior)
UPDATE public.admin_notifications
SET auto_dismiss_hours = GREATEST(1, LEAST(720,
    EXTRACT(EPOCH FROM (expires_at - sent_at)) / 3600
))::INTEGER
WHERE auto_dismiss_hours IS NULL;

-- -----------------------------------------------------
-- Update RPC Functions to support auto_dismiss_hours
-- -----------------------------------------------------

-- Update get_user_notifications to include expires_at
CREATE OR REPLACE FUNCTION public.get_user_notifications(
    p_include_dismissed BOOLEAN DEFAULT false
)
RETURNS TABLE (
    id UUID,
    notification_id UUID,
    title TEXT,
    message TEXT,
    priority TEXT,
    deep_link TEXT,
    sent_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    auto_dismiss_hours INTEGER,
    is_read BOOLEAN,
    read_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT
        un.id,
        an.id AS notification_id,
        an.title,
        an.message,
        an.priority,
        an.deep_link,
        an.sent_at,
        an.expires_at,
        an.auto_dismiss_hours,
        un.is_read,
        un.read_at,
        un.dismissed_at
    FROM public.user_notifications un
    JOIN public.admin_notifications an ON un.notification_id = an.id
    WHERE un.user_id = auth.uid()
    AND an.expires_at > now()
    AND (p_include_dismissed OR un.dismissed_at IS NULL)
    ORDER BY an.sent_at DESC;
END;
$$;

-- Update send_broadcast_notification to accept auto_dismiss_hours
CREATE OR REPLACE FUNCTION public.send_broadcast_notification(
    p_title TEXT,
    p_message TEXT,
    p_priority TEXT DEFAULT 'normal',
    p_deep_link TEXT DEFAULT NULL,
    p_auto_dismiss_hours INTEGER DEFAULT 48
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_notification_id UUID;
    v_sent_count INTEGER;
    v_is_admin BOOLEAN;
BEGIN
    -- Check if user is admin
    SELECT (raw_user_meta_data->>'is_admin')::boolean INTO v_is_admin
    FROM auth.users
    WHERE id = auth.uid();

    IF NOT COALESCE(v_is_admin, false) THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    -- Validate priority
    IF p_priority NOT IN ('normal', 'important', 'urgent') THEN
        RAISE EXCEPTION 'Invalid priority: must be normal, important, or urgent';
    END IF;

    -- Validate auto_dismiss_hours
    IF p_auto_dismiss_hours < 1 OR p_auto_dismiss_hours > 720 THEN
        RAISE EXCEPTION 'auto_dismiss_hours must be between 1 and 720';
    END IF;

    -- Create the notification (trigger will calculate expires_at)
    INSERT INTO public.admin_notifications (title, message, priority, deep_link, sent_by, auto_dismiss_hours)
    VALUES (p_title, p_message, p_priority, p_deep_link, auth.uid(), p_auto_dismiss_hours)
    RETURNING id INTO v_notification_id;

    -- Create user_notification records for all users
    INSERT INTO public.user_notifications (user_id, notification_id)
    SELECT p.id, v_notification_id
    FROM public.profiles p
    WHERE p.id IS NOT NULL;

    GET DIAGNOSTICS v_sent_count = ROW_COUNT;

    RETURN json_build_object(
        'notification_id', v_notification_id,
        'sent_count', v_sent_count,
        'success', true
    );
END;
$$;

-- Update get_admin_broadcast_history to include auto_dismiss_hours
CREATE OR REPLACE FUNCTION public.get_admin_broadcast_history()
RETURNS TABLE (
    id UUID,
    title TEXT,
    message TEXT,
    priority TEXT,
    deep_link TEXT,
    sent_by UUID,
    sent_by_email TEXT,
    sent_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    auto_dismiss_hours INTEGER,
    sent_count BIGINT,
    read_count BIGINT,
    dismissed_count BIGINT,
    click_count BIGINT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_is_admin BOOLEAN;
BEGIN
    -- Check if user is admin
    SELECT (raw_user_meta_data->>'is_admin')::boolean INTO v_is_admin
    FROM auth.users
    WHERE id = auth.uid();

    IF NOT COALESCE(v_is_admin, false) THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    RETURN QUERY
    SELECT
        an.id,
        an.title,
        an.message,
        an.priority,
        an.deep_link,
        an.sent_by,
        p.email AS sent_by_email,
        an.sent_at,
        an.expires_at,
        an.auto_dismiss_hours,
        COUNT(un.id) AS sent_count,
        COUNT(un.id) FILTER (WHERE un.is_read = true) AS read_count,
        COUNT(un.id) FILTER (WHERE un.dismissed_at IS NOT NULL) AS dismissed_count,
        COUNT(un.id) FILTER (WHERE un.clicked_deep_link = true) AS click_count
    FROM public.admin_notifications an
    LEFT JOIN public.user_notifications un ON an.id = un.notification_id
    LEFT JOIN public.profiles p ON an.sent_by = p.id
    GROUP BY an.id, an.title, an.message, an.priority, an.deep_link,
             an.sent_by, p.email, an.sent_at, an.expires_at, an.auto_dismiss_hours
    ORDER BY an.sent_at DESC;
END;
$$;

-- Grant execute permissions for the updated functions
GRANT EXECUTE ON FUNCTION public.get_user_notifications(BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.send_broadcast_notification(TEXT, TEXT, TEXT, TEXT, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_broadcast_history() TO authenticated;
