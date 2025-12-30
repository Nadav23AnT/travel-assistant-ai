-- Add custom action button text to admin_notifications
-- Allows admin to customize the "View Details" button text

ALTER TABLE public.admin_notifications
ADD COLUMN IF NOT EXISTS action_button_text TEXT DEFAULT 'View Details';

-- Add to user_notifications view for display
COMMENT ON COLUMN public.admin_notifications.action_button_text IS
    'Custom text for the action button displayed in notifications. Defaults to "View Details"';

-- Drop and recreate get_admin_broadcast_history (return type changed - added action_button_text)
DROP FUNCTION IF EXISTS public.get_admin_broadcast_history();

CREATE FUNCTION public.get_admin_broadcast_history()
RETURNS TABLE(
    id uuid,
    title text,
    message text,
    priority text,
    deep_link text,
    action_button_text text,
    sent_by uuid,
    sent_by_email text,
    sent_at timestamp with time zone,
    expires_at timestamp with time zone,
    auto_dismiss_hours integer,
    sent_count bigint,
    read_count bigint,
    dismissed_count bigint,
    click_count bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    v_is_admin BOOLEAN;
BEGIN
    SELECT p.is_admin INTO v_is_admin
    FROM public.profiles p
    WHERE p.id = auth.uid();

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
        COALESCE(an.action_button_text, 'View Details') AS action_button_text,
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
    GROUP BY an.id, an.title, an.message, an.priority, an.deep_link, an.action_button_text,
             an.sent_by, p.email, an.sent_at, an.expires_at, an.auto_dismiss_hours
    ORDER BY an.sent_at DESC;
END;
$$;

-- Drop ALL versions of get_user_notifications and recreate without parameters
-- The old version had (p_include_dismissed BOOLEAN) parameter, new version has none
DROP FUNCTION IF EXISTS public.get_user_notifications();
DROP FUNCTION IF EXISTS public.get_user_notifications(boolean);

CREATE FUNCTION public.get_user_notifications()
RETURNS TABLE(
    id uuid,
    notification_id uuid,
    title text,
    message text,
    priority text,
    deep_link text,
    action_button_text text,
    sent_at timestamp with time zone,
    expires_at timestamp with time zone,
    auto_dismiss_hours integer,
    is_read boolean,
    read_at timestamp with time zone,
    dismissed_at timestamp with time zone
)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'public'
STABLE
AS $$
    SELECT
        un.id,
        un.notification_id,
        an.title,
        an.message,
        an.priority,
        an.deep_link,
        COALESCE(an.action_button_text, 'View Details') AS action_button_text,
        an.sent_at,
        an.expires_at,
        an.auto_dismiss_hours,
        un.is_read,
        un.read_at,
        un.dismissed_at
    FROM public.user_notifications un
    JOIN public.admin_notifications an ON un.notification_id = an.id
    WHERE un.user_id = auth.uid()
      AND un.dismissed_at IS NULL
      AND an.expires_at > NOW()
    ORDER BY an.sent_at DESC;
$$;

-- Re-grant execute permissions (lost when functions are dropped)
GRANT EXECUTE ON FUNCTION public.get_admin_broadcast_history() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_notifications() TO authenticated;
