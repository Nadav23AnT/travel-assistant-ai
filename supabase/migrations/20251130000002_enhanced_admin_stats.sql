-- =============================================
-- Enhanced Admin Statistics
-- Adds comprehensive analytics for admin dashboard
-- =============================================

-- =============================================
-- 1. Enhanced System Stats Function
-- =============================================

CREATE OR REPLACE FUNCTION public.get_admin_system_stats()
RETURNS JSON AS $$
DECLARE
    stats JSON;
    active_threshold INTERVAL := '15 minutes';
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    SELECT json_build_object(
        -- Basic counts
        'total_users', (SELECT COUNT(*) FROM public.profiles),
        'total_trips', (SELECT COUNT(*) FROM public.trips),
        'active_trips', (SELECT COUNT(*) FROM public.trips WHERE status = 'active'),
        'total_expenses', (SELECT COUNT(*) FROM public.expenses),
        'total_chat_sessions', (SELECT COUNT(*) FROM public.chat_sessions),
        'open_support_tickets', (SELECT COUNT(*) FROM public.support_sessions WHERE status IN ('open', 'in_progress')),

        -- Growth stats
        'users_today', (SELECT COUNT(*) FROM public.profiles WHERE created_at >= CURRENT_DATE),
        'users_this_week', (SELECT COUNT(*) FROM public.profiles WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'),
        'users_this_month', (SELECT COUNT(*) FROM public.profiles WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'),
        'premium_users', (SELECT COUNT(*) FROM public.profiles WHERE plan_type = 'subscription'),

        -- Active users (based on chat activity)
        'active_users_today', (SELECT COUNT(DISTINCT user_id) FROM public.chat_sessions WHERE updated_at >= CURRENT_DATE),
        'active_users_week', (SELECT COUNT(DISTINCT user_id) FROM public.chat_sessions WHERE updated_at >= CURRENT_DATE - INTERVAL '7 days'),
        'active_users_month', (SELECT COUNT(DISTINCT user_id) FROM public.chat_sessions WHERE updated_at >= CURRENT_DATE - INTERVAL '30 days'),

        -- "Live" users (active in last 15 minutes based on chat_sessions)
        'live_users', (SELECT COUNT(DISTINCT user_id) FROM public.chat_sessions WHERE updated_at >= NOW() - active_threshold),

        -- Token usage stats
        'total_tokens_today', (SELECT COALESCE(SUM(tokens_used), 0) FROM public.daily_token_usage WHERE usage_date = CURRENT_DATE),
        'total_tokens_week', (SELECT COALESCE(SUM(tokens_used), 0) FROM public.daily_token_usage WHERE usage_date >= CURRENT_DATE - INTERVAL '7 days'),
        'avg_tokens_per_user', (
            SELECT COALESCE(ROUND(AVG(tokens_used)), 0)
            FROM public.daily_token_usage
            WHERE usage_date = CURRENT_DATE AND tokens_used > 0
        ),
        'total_requests_today', (SELECT COALESCE(SUM(request_count), 0) FROM public.daily_token_usage WHERE usage_date = CURRENT_DATE),

        -- Trip stats
        'trips_created_today', (SELECT COUNT(*) FROM public.trips WHERE created_at >= CURRENT_DATE),
        'trips_created_week', (SELECT COUNT(*) FROM public.trips WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'),

        -- Expense stats
        'expenses_logged_today', (SELECT COUNT(*) FROM public.expenses WHERE created_at >= CURRENT_DATE),
        'total_expense_amount_today', (SELECT COALESCE(SUM(amount), 0) FROM public.expenses WHERE created_at >= CURRENT_DATE),

        -- Chat engagement
        'chat_messages_today', (SELECT COUNT(*) FROM public.chat_messages WHERE created_at >= CURRENT_DATE),
        'avg_messages_per_session', (
            SELECT COALESCE(ROUND(AVG(msg_count)), 0)
            FROM (
                SELECT session_id, COUNT(*) as msg_count
                FROM public.chat_messages
                WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
                GROUP BY session_id
            ) sub
        )
    ) INTO stats;

    RETURN stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 2. User Growth Trend Function (last 30 days)
-- =============================================

CREATE OR REPLACE FUNCTION public.get_admin_user_growth_trend()
RETURNS TABLE (
    date DATE,
    new_users BIGINT,
    cumulative_users BIGINT
) AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    RETURN QUERY
    WITH daily_signups AS (
        SELECT
            DATE(created_at) as signup_date,
            COUNT(*) as daily_count
        FROM public.profiles
        WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY DATE(created_at)
    ),
    date_series AS (
        SELECT generate_series(
            CURRENT_DATE - INTERVAL '30 days',
            CURRENT_DATE,
            INTERVAL '1 day'
        )::DATE as date
    )
    SELECT
        ds.date,
        COALESCE(d.daily_count, 0) as new_users,
        (SELECT COUNT(*) FROM public.profiles WHERE DATE(created_at) <= ds.date) as cumulative_users
    FROM date_series ds
    LEFT JOIN daily_signups d ON ds.date = d.signup_date
    ORDER BY ds.date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- 3. Token Usage Trend Function (last 14 days)
-- =============================================

CREATE OR REPLACE FUNCTION public.get_admin_token_usage_trend()
RETURNS TABLE (
    date DATE,
    total_tokens BIGINT,
    total_requests BIGINT,
    unique_users BIGINT
) AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    RETURN QUERY
    WITH date_series AS (
        SELECT generate_series(
            CURRENT_DATE - INTERVAL '14 days',
            CURRENT_DATE,
            INTERVAL '1 day'
        )::DATE as date
    )
    SELECT
        ds.date,
        COALESCE(SUM(dtu.tokens_used), 0)::BIGINT as total_tokens,
        COALESCE(SUM(dtu.request_count), 0)::BIGINT as total_requests,
        COUNT(DISTINCT dtu.user_id)::BIGINT as unique_users
    FROM date_series ds
    LEFT JOIN public.daily_token_usage dtu ON ds.date = dtu.usage_date
    GROUP BY ds.date
    ORDER BY ds.date;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- 4. Peak Usage Hours Function
-- =============================================

CREATE OR REPLACE FUNCTION public.get_admin_peak_usage_hours()
RETURNS TABLE (
    hour INTEGER,
    message_count BIGINT
) AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    RETURN QUERY
    SELECT
        EXTRACT(HOUR FROM created_at)::INTEGER as hour,
        COUNT(*)::BIGINT as message_count
    FROM public.chat_messages
    WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
    GROUP BY EXTRACT(HOUR FROM created_at)
    ORDER BY hour;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- 5. Grant Permissions
-- =============================================

GRANT EXECUTE ON FUNCTION public.get_admin_user_growth_trend TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_token_usage_trend TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_peak_usage_hours TO authenticated;
