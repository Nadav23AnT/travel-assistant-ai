-- Fix get_user_notifications to accept p_include_dismissed parameter
-- The Flutter code calls this with a parameter, so we need to support it

-- Drop the no-parameter version we just created
DROP FUNCTION IF EXISTS public.get_user_notifications();

-- Create the function with the p_include_dismissed parameter
CREATE FUNCTION public.get_user_notifications(p_include_dismissed boolean DEFAULT false)
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
    dismissed_at timestamp with time zone,
    is_rtl boolean
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
        un.dismissed_at,
        COALESCE(an.is_rtl, false) AS is_rtl
    FROM public.user_notifications un
    JOIN public.admin_notifications an ON un.notification_id = an.id
    WHERE un.user_id = auth.uid()
      AND (p_include_dismissed OR un.dismissed_at IS NULL)
      AND an.expires_at > NOW()
    ORDER BY an.sent_at DESC;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_user_notifications(boolean) TO authenticated;
