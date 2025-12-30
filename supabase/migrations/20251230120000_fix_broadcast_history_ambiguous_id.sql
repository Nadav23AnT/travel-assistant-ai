-- Fix ambiguous column reference in get_admin_broadcast_history
-- The RETURNS TABLE creates an 'id' variable that conflicts with profiles.id
-- FIX: Use table alias 'p' and qualify as p.id instead of just 'id'

CREATE OR REPLACE FUNCTION public.get_admin_broadcast_history()
RETURNS TABLE(
    id uuid,
    title text,
    message text,
    priority text,
    deep_link text,
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
    -- FIX: Use alias 'p' and qualify column as p.id to avoid ambiguity
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
