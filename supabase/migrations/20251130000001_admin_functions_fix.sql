-- =============================================
-- FIX: Admin Functions with Correct Schema
-- - Uses owner_id for trips (not user_id)
-- - Uses paid_by for expenses (not user_id)
-- - Gets subscription from subscriptions table (not profiles)
-- - Uses SECURITY DEFINER to bypass RLS
-- =============================================

-- =============================================
-- 1. Drop Problematic RLS Policies
-- =============================================

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all trips" ON public.trips;
DROP POLICY IF EXISTS "Admins can view all expenses" ON public.expenses;
DROP POLICY IF EXISTS "Admins can view all chat sessions" ON public.chat_sessions;
DROP POLICY IF EXISTS "Admins can manage all token usage" ON public.daily_token_usage;
DROP POLICY IF EXISTS "Admins can view all user settings" ON public.user_settings;
DROP POLICY IF EXISTS "Admins can view all support sessions" ON public.support_sessions;
DROP POLICY IF EXISTS "Admins can update all support sessions" ON public.support_sessions;
DROP POLICY IF EXISTS "Admins can view all messages" ON public.support_messages;
DROP POLICY IF EXISTS "Admins can send messages" ON public.support_messages;
DROP POLICY IF EXISTS "Admins can update messages" ON public.support_messages;

-- =============================================
-- 2. Create/Update is_admin() Function
-- =============================================

CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = user_uuid AND is_admin = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- 3. Recreate RLS Policies using is_admin()
-- =============================================

-- Trips
CREATE POLICY "Admins can view all trips"
    ON public.trips FOR SELECT
    USING (public.is_admin());

-- Expenses
CREATE POLICY "Admins can view all expenses"
    ON public.expenses FOR SELECT
    USING (public.is_admin());

-- Chat sessions
CREATE POLICY "Admins can view all chat sessions"
    ON public.chat_sessions FOR SELECT
    USING (public.is_admin());

-- Token usage
CREATE POLICY "Admins can manage all token usage"
    ON public.daily_token_usage FOR ALL
    USING (user_id = auth.uid() OR public.is_admin());

-- User settings
CREATE POLICY "Admins can view all user settings"
    ON public.user_settings FOR SELECT
    USING (public.is_admin());

-- Support sessions
CREATE POLICY "Admins can view all support sessions"
    ON public.support_sessions FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admins can update all support sessions"
    ON public.support_sessions FOR UPDATE
    USING (public.is_admin());

-- Support messages
CREATE POLICY "Admins can view all messages"
    ON public.support_messages FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admins can send messages"
    ON public.support_messages FOR INSERT
    WITH CHECK (
        public.is_admin()
        AND sender_role = 'admin'
        AND sender_id = auth.uid()
    );

CREATE POLICY "Admins can update messages"
    ON public.support_messages FOR UPDATE
    USING (public.is_admin());

-- =============================================
-- 4. Admin Get All Users Function
-- =============================================

CREATE OR REPLACE FUNCTION public.admin_get_all_users(
    p_page INTEGER DEFAULT 0,
    p_limit INTEGER DEFAULT 50,
    p_search TEXT DEFAULT NULL,
    p_plan_filter TEXT DEFAULT NULL,
    p_sort_by TEXT DEFAULT 'created_at',
    p_ascending BOOLEAN DEFAULT false
)
RETURNS TABLE (
    id UUID,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    default_currency TEXT,
    plan_type TEXT,
    is_admin BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    trips_count BIGINT,
    expenses_count BIGINT,
    total_expenses NUMERIC,
    chat_sessions_count BIGINT,
    today_tokens_used BIGINT,
    daily_token_limit INTEGER,
    last_activity_at TIMESTAMPTZ,
    subscription_status TEXT,
    subscription_expires_at TIMESTAMPTZ
) AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    RETURN QUERY
    SELECT
        p.id,
        p.email::TEXT,
        p.full_name::TEXT,
        p.avatar_url::TEXT,
        p.default_currency::TEXT,
        p.plan_type::TEXT,
        p.is_admin,
        p.created_at,
        p.updated_at,
        COALESCE((SELECT COUNT(*) FROM public.trips t WHERE t.owner_id = p.id), 0) AS trips_count,
        COALESCE((SELECT COUNT(*) FROM public.expenses e WHERE e.paid_by = p.id), 0) AS expenses_count,
        COALESCE((SELECT SUM(e.amount) FROM public.expenses e WHERE e.paid_by = p.id), 0) AS total_expenses,
        COALESCE((SELECT COUNT(*) FROM public.chat_sessions cs WHERE cs.user_id = p.id), 0) AS chat_sessions_count,
        COALESCE((SELECT SUM(dtu.tokens_used) FROM public.daily_token_usage dtu
            WHERE dtu.user_id = p.id AND dtu.usage_date = CURRENT_DATE), 0) AS today_tokens_used,
        CASE WHEN p.plan_type = 'subscription' THEN 100000 ELSE 10000 END AS daily_token_limit,
        (SELECT MAX(cs.updated_at) FROM public.chat_sessions cs WHERE cs.user_id = p.id) AS last_activity_at,
        (SELECT s.status FROM public.subscriptions s WHERE s.user_id = p.id LIMIT 1)::TEXT AS subscription_status,
        (SELECT s.current_period_end FROM public.subscriptions s WHERE s.user_id = p.id LIMIT 1) AS subscription_expires_at
    FROM public.profiles p
    WHERE
        (p_search IS NULL OR p_search = '' OR
         p.email ILIKE '%' || p_search || '%' OR
         p.full_name ILIKE '%' || p_search || '%')
        AND (p_plan_filter IS NULL OR p_plan_filter = '' OR p.plan_type = p_plan_filter)
    ORDER BY
        CASE WHEN p_sort_by = 'email' AND NOT p_ascending THEN p.email END DESC,
        CASE WHEN p_sort_by = 'email' AND p_ascending THEN p.email END ASC,
        CASE WHEN p_sort_by = 'full_name' AND NOT p_ascending THEN p.full_name END DESC,
        CASE WHEN p_sort_by = 'full_name' AND p_ascending THEN p.full_name END ASC,
        CASE WHEN p_sort_by = 'plan_type' AND NOT p_ascending THEN p.plan_type END DESC,
        CASE WHEN p_sort_by = 'plan_type' AND p_ascending THEN p.plan_type END ASC,
        CASE WHEN (p_sort_by = 'created_at' OR p_sort_by IS NULL) AND NOT p_ascending THEN p.created_at END DESC,
        CASE WHEN (p_sort_by = 'created_at' OR p_sort_by IS NULL) AND p_ascending THEN p.created_at END ASC
    LIMIT p_limit
    OFFSET p_page * p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- 5. Admin Get User By ID Function
-- =============================================

CREATE OR REPLACE FUNCTION public.admin_get_user_by_id(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    default_currency TEXT,
    plan_type TEXT,
    is_admin BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    trips_count BIGINT,
    expenses_count BIGINT,
    total_expenses NUMERIC,
    chat_sessions_count BIGINT,
    today_tokens_used BIGINT,
    daily_token_limit INTEGER,
    last_activity_at TIMESTAMPTZ,
    subscription_status TEXT,
    subscription_expires_at TIMESTAMPTZ
) AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    RETURN QUERY
    SELECT
        p.id,
        p.email::TEXT,
        p.full_name::TEXT,
        p.avatar_url::TEXT,
        p.default_currency::TEXT,
        p.plan_type::TEXT,
        p.is_admin,
        p.created_at,
        p.updated_at,
        COALESCE((SELECT COUNT(*) FROM public.trips t WHERE t.owner_id = p.id), 0) AS trips_count,
        COALESCE((SELECT COUNT(*) FROM public.expenses e WHERE e.paid_by = p.id), 0) AS expenses_count,
        COALESCE((SELECT SUM(e.amount) FROM public.expenses e WHERE e.paid_by = p.id), 0) AS total_expenses,
        COALESCE((SELECT COUNT(*) FROM public.chat_sessions cs WHERE cs.user_id = p.id), 0) AS chat_sessions_count,
        COALESCE((SELECT SUM(dtu.tokens_used) FROM public.daily_token_usage dtu
            WHERE dtu.user_id = p.id AND dtu.usage_date = CURRENT_DATE), 0) AS today_tokens_used,
        CASE WHEN p.plan_type = 'subscription' THEN 100000 ELSE 10000 END AS daily_token_limit,
        (SELECT MAX(cs.updated_at) FROM public.chat_sessions cs WHERE cs.user_id = p.id) AS last_activity_at,
        (SELECT s.status FROM public.subscriptions s WHERE s.user_id = p.id LIMIT 1)::TEXT AS subscription_status,
        (SELECT s.current_period_end FROM public.subscriptions s WHERE s.user_id = p.id LIMIT 1) AS subscription_expires_at
    FROM public.profiles p
    WHERE p.id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- 6. Admin Set User Admin Status Function
-- =============================================

CREATE OR REPLACE FUNCTION public.admin_set_user_admin_status(
    p_user_id UUID,
    p_is_admin BOOLEAN
)
RETURNS BOOLEAN AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    UPDATE public.profiles
    SET is_admin = p_is_admin, updated_at = NOW()
    WHERE id = p_user_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 7. Admin Get User Count By Plan Function
-- =============================================

CREATE OR REPLACE FUNCTION public.admin_get_user_count_by_plan()
RETURNS TABLE (
    plan_type TEXT,
    count BIGINT
) AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    RETURN QUERY
    SELECT p.plan_type::TEXT, COUNT(*) as count
    FROM public.profiles p
    GROUP BY p.plan_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =============================================
-- 8. Admin Delete User Data Function
-- =============================================

CREATE OR REPLACE FUNCTION public.admin_delete_user_data(
    p_user_id UUID,
    p_data_type TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    CASE p_data_type
        WHEN 'expenses' THEN
            DELETE FROM public.expenses WHERE paid_by = p_user_id;
        WHEN 'trips' THEN
            DELETE FROM public.trips WHERE owner_id = p_user_id;
        WHEN 'chatHistory' THEN
            DELETE FROM public.chat_messages
            WHERE session_id IN (SELECT id FROM public.chat_sessions WHERE user_id = p_user_id);
            DELETE FROM public.chat_sessions WHERE user_id = p_user_id;
        WHEN 'journalEntries' THEN
            DELETE FROM public.journal_entries WHERE user_id = p_user_id;
        WHEN 'tokenUsage' THEN
            DELETE FROM public.daily_token_usage WHERE user_id = p_user_id;
        WHEN 'all' THEN
            DELETE FROM public.chat_messages
            WHERE session_id IN (SELECT id FROM public.chat_sessions WHERE user_id = p_user_id);
            DELETE FROM public.chat_sessions WHERE user_id = p_user_id;
            DELETE FROM public.journal_entries WHERE user_id = p_user_id;
            DELETE FROM public.expenses WHERE paid_by = p_user_id;
            DELETE FROM public.trips WHERE owner_id = p_user_id;
            DELETE FROM public.daily_token_usage WHERE user_id = p_user_id;
        ELSE
            RAISE EXCEPTION 'Invalid data type: %', p_data_type;
    END CASE;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 9. Fix get_admin_system_stats Function
-- =============================================

CREATE OR REPLACE FUNCTION public.get_admin_system_stats()
RETURNS JSON AS $$
DECLARE
    stats JSON;
BEGIN
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    SELECT json_build_object(
        'total_users', (SELECT COUNT(*) FROM public.profiles),
        'total_trips', (SELECT COUNT(*) FROM public.trips),
        'active_trips', (SELECT COUNT(*) FROM public.trips WHERE status = 'active'),
        'total_expenses', (SELECT COUNT(*) FROM public.expenses),
        'total_chat_sessions', (SELECT COUNT(*) FROM public.chat_sessions),
        'open_support_tickets', (SELECT COUNT(*) FROM public.support_sessions WHERE status IN ('open', 'in_progress')),
        'users_today', (SELECT COUNT(*) FROM public.profiles WHERE created_at >= CURRENT_DATE),
        'premium_users', (SELECT COUNT(*) FROM public.profiles WHERE plan_type = 'subscription')
    ) INTO stats;

    RETURN stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 10. Grant Permissions
-- =============================================

GRANT EXECUTE ON FUNCTION public.is_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_all_users TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_user_by_id TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_set_user_admin_status TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_get_user_count_by_plan TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_user_data TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_system_stats TO authenticated;
