-- =====================================================
-- Admin Broadcast Notifications Schema
-- =====================================================
-- This migration creates tables and functions for admin
-- broadcast notifications to all users.
-- =====================================================

-- -----------------------------------------------------
-- Table: admin_notifications
-- Stores broadcast notifications sent by admins
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.admin_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL CHECK (char_length(title) >= 1 AND char_length(title) <= 60),
    message TEXT NOT NULL CHECK (char_length(message) >= 1 AND char_length(message) <= 500),
    priority TEXT NOT NULL DEFAULT 'normal' CHECK (priority IN ('normal', 'important', 'urgent')),
    deep_link TEXT,
    sent_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    sent_at TIMESTAMPTZ DEFAULT now(),
    expires_at TIMESTAMPTZ DEFAULT (now() + INTERVAL '7 days'),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Add comment for documentation
COMMENT ON TABLE public.admin_notifications IS 'Stores broadcast notifications sent by admins to all users';
COMMENT ON COLUMN public.admin_notifications.priority IS 'Notification priority: normal, important, or urgent';
COMMENT ON COLUMN public.admin_notifications.deep_link IS 'Optional deep link to navigate user to specific screen';
COMMENT ON COLUMN public.admin_notifications.expires_at IS 'Notification auto-expires and gets cleaned up after this time';

-- Index for efficient queries
CREATE INDEX IF NOT EXISTS idx_admin_notifications_sent_at ON public.admin_notifications(sent_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_expires_at ON public.admin_notifications(expires_at);

-- -----------------------------------------------------
-- Table: user_notifications
-- Tracks per-user notification status (read/dismissed)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS public.user_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_id UUID NOT NULL REFERENCES public.admin_notifications(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    dismissed_at TIMESTAMPTZ,
    clicked_deep_link BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, notification_id)
);

-- Add comment for documentation
COMMENT ON TABLE public.user_notifications IS 'Tracks per-user read/dismissed status for each notification';

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_user_notifications_user_id ON public.user_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_user_notifications_notification_id ON public.user_notifications(notification_id);
CREATE INDEX IF NOT EXISTS idx_user_notifications_is_read ON public.user_notifications(user_id, is_read) WHERE is_read = false;

-- -----------------------------------------------------
-- Row Level Security Policies
-- -----------------------------------------------------

-- Enable RLS
ALTER TABLE public.admin_notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

-- admin_notifications policies
-- Admins can do everything, regular users can only read
CREATE POLICY "Admins can manage notifications" ON public.admin_notifications
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM auth.users
            WHERE auth.users.id = auth.uid()
            AND (auth.users.raw_user_meta_data->>'is_admin')::boolean = true
        )
    );

CREATE POLICY "Users can view active notifications" ON public.admin_notifications
    FOR SELECT
    USING (expires_at > now());

-- user_notifications policies
-- Users can only see and manage their own notification records
CREATE POLICY "Users can view own notifications" ON public.user_notifications
    FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications" ON public.user_notifications
    FOR UPDATE
    USING (user_id = auth.uid());

-- System can insert for any user (used by broadcast function)
CREATE POLICY "System can insert notifications" ON public.user_notifications
    FOR INSERT
    WITH CHECK (true);

-- -----------------------------------------------------
-- RPC Functions
-- -----------------------------------------------------

-- Function: Get user's notifications with full details
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

-- Function: Get unread notification count
CREATE OR REPLACE FUNCTION public.get_unread_notification_count()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)::INTEGER INTO v_count
    FROM public.user_notifications un
    JOIN public.admin_notifications an ON un.notification_id = an.id
    WHERE un.user_id = auth.uid()
    AND un.is_read = false
    AND un.dismissed_at IS NULL
    AND an.expires_at > now();

    RETURN v_count;
END;
$$;

-- Function: Mark notification as read
CREATE OR REPLACE FUNCTION public.mark_notification_read(
    p_notification_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_notifications
    SET
        is_read = true,
        read_at = COALESCE(read_at, now())
    WHERE user_id = auth.uid()
    AND notification_id = p_notification_id;

    RETURN FOUND;
END;
$$;

-- Function: Dismiss notification
CREATE OR REPLACE FUNCTION public.dismiss_notification(
    p_notification_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_notifications
    SET
        dismissed_at = now(),
        is_read = true,
        read_at = COALESCE(read_at, now())
    WHERE user_id = auth.uid()
    AND notification_id = p_notification_id;

    RETURN FOUND;
END;
$$;

-- Function: Mark all notifications as read
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    WITH updated AS (
        UPDATE public.user_notifications
        SET
            is_read = true,
            read_at = COALESCE(read_at, now())
        WHERE user_id = auth.uid()
        AND is_read = false
        RETURNING 1
    )
    SELECT COUNT(*)::INTEGER INTO v_count FROM updated;

    RETURN v_count;
END;
$$;

-- Function: Record deep link click
CREATE OR REPLACE FUNCTION public.record_notification_click(
    p_notification_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE public.user_notifications
    SET
        clicked_deep_link = true,
        is_read = true,
        read_at = COALESCE(read_at, now())
    WHERE user_id = auth.uid()
    AND notification_id = p_notification_id;

    RETURN FOUND;
END;
$$;

-- -----------------------------------------------------
-- Admin Functions (SECURITY DEFINER to bypass RLS)
-- -----------------------------------------------------

-- Function: Send broadcast notification (admin only)
CREATE OR REPLACE FUNCTION public.send_broadcast_notification(
    p_title TEXT,
    p_message TEXT,
    p_priority TEXT DEFAULT 'normal',
    p_deep_link TEXT DEFAULT NULL
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

    -- Create the notification
    INSERT INTO public.admin_notifications (title, message, priority, deep_link, sent_by)
    VALUES (p_title, p_message, p_priority, p_deep_link, auth.uid())
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

-- Function: Get admin broadcast history with stats
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
        COUNT(un.id) AS sent_count,
        COUNT(un.id) FILTER (WHERE un.is_read = true) AS read_count,
        COUNT(un.id) FILTER (WHERE un.dismissed_at IS NOT NULL) AS dismissed_count,
        COUNT(un.id) FILTER (WHERE un.clicked_deep_link = true) AS click_count
    FROM public.admin_notifications an
    LEFT JOIN public.user_notifications un ON an.id = un.notification_id
    LEFT JOIN public.profiles p ON an.sent_by = p.id
    GROUP BY an.id, an.title, an.message, an.priority, an.deep_link,
             an.sent_by, p.email, an.sent_at, an.expires_at
    ORDER BY an.sent_at DESC;
END;
$$;

-- Function: Cleanup expired notifications (for cron job)
CREATE OR REPLACE FUNCTION public.cleanup_expired_notifications()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_deleted_count INTEGER;
BEGIN
    -- Delete expired notifications (cascades to user_notifications)
    WITH deleted AS (
        DELETE FROM public.admin_notifications
        WHERE expires_at < now()
        RETURNING 1
    )
    SELECT COUNT(*)::INTEGER INTO v_deleted_count FROM deleted;

    RETURN v_deleted_count;
END;
$$;

-- -----------------------------------------------------
-- Cron Job for Cleanup (requires pg_cron extension)
-- -----------------------------------------------------
-- Note: Run this manually or via Supabase dashboard if pg_cron is available
-- SELECT cron.schedule('cleanup-expired-notifications', '0 2 * * *', 'SELECT public.cleanup_expired_notifications()');

-- -----------------------------------------------------
-- Grant Execute Permissions
-- -----------------------------------------------------
GRANT EXECUTE ON FUNCTION public.get_user_notifications(BOOLEAN) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_unread_notification_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_notification_read(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.dismiss_notification(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_all_notifications_read() TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_notification_click(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.send_broadcast_notification(TEXT, TEXT, TEXT, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_broadcast_history() TO authenticated;
GRANT EXECUTE ON FUNCTION public.cleanup_expired_notifications() TO authenticated;
