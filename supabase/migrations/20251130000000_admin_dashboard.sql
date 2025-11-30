-- =============================================
-- Admin Dashboard Schema Migration
-- Adds admin role, support chat system, and admin policies
-- =============================================

-- =============================================
-- 1. Add Admin Role to Profiles
-- =============================================

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

-- Create index for admin lookups
CREATE INDEX IF NOT EXISTS idx_profiles_is_admin ON public.profiles(is_admin) WHERE is_admin = true;

-- =============================================
-- 2. Create Support Sessions Table
-- =============================================

CREATE TABLE IF NOT EXISTS public.support_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    admin_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    subject TEXT NOT NULL,
    status TEXT DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    unread_admin_count INTEGER DEFAULT 0,
    unread_user_count INTEGER DEFAULT 0
);

-- Indexes for support sessions
CREATE INDEX IF NOT EXISTS idx_support_sessions_user ON public.support_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_support_sessions_admin ON public.support_sessions(admin_id);
CREATE INDEX IF NOT EXISTS idx_support_sessions_status ON public.support_sessions(status);
CREATE INDEX IF NOT EXISTS idx_support_sessions_created ON public.support_sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_support_sessions_last_message ON public.support_sessions(last_message_at DESC);

-- =============================================
-- 3. Create Support Messages Table
-- =============================================

CREATE TABLE IF NOT EXISTS public.support_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.support_sessions(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    sender_role TEXT NOT NULL CHECK (sender_role IN ('user', 'admin')),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for support messages
CREATE INDEX IF NOT EXISTS idx_support_messages_session ON public.support_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_support_messages_created ON public.support_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_support_messages_unread ON public.support_messages(session_id, is_read) WHERE is_read = false;

-- =============================================
-- 4. Enable Row Level Security
-- =============================================

ALTER TABLE public.support_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- =============================================
-- 5. Support Sessions RLS Policies
-- =============================================

-- Users can view their own support sessions
CREATE POLICY "Users can view own support sessions"
    ON public.support_sessions FOR SELECT
    USING (auth.uid() = user_id);

-- Users can create support sessions for themselves
CREATE POLICY "Users can create own support sessions"
    ON public.support_sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own sessions (limited - mainly for closing)
CREATE POLICY "Users can update own support sessions"
    ON public.support_sessions FOR UPDATE
    USING (auth.uid() = user_id);

-- Admins can view all support sessions
CREATE POLICY "Admins can view all support sessions"
    ON public.support_sessions FOR SELECT
    USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

-- Admins can update all support sessions
CREATE POLICY "Admins can update all support sessions"
    ON public.support_sessions FOR UPDATE
    USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

-- =============================================
-- 6. Support Messages RLS Policies
-- =============================================

-- Users can view messages in their sessions
CREATE POLICY "Users can view own session messages"
    ON public.support_messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.support_sessions
            WHERE id = support_messages.session_id AND user_id = auth.uid()
        )
    );

-- Users can send messages in their sessions (as user role only)
CREATE POLICY "Users can send messages in own sessions"
    ON public.support_messages FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.support_sessions
            WHERE id = support_messages.session_id AND user_id = auth.uid()
        )
        AND sender_role = 'user'
        AND sender_id = auth.uid()
    );

-- Admins can view all messages
CREATE POLICY "Admins can view all messages"
    ON public.support_messages FOR SELECT
    USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

-- Admins can send messages (as admin role)
CREATE POLICY "Admins can send messages"
    ON public.support_messages FOR INSERT
    WITH CHECK (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
        AND sender_role = 'admin'
        AND sender_id = auth.uid()
    );

-- Admins can update messages (for marking as read)
CREATE POLICY "Admins can update messages"
    ON public.support_messages FOR UPDATE
    USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

-- Users can update messages in their sessions (for marking as read)
CREATE POLICY "Users can update own session messages"
    ON public.support_messages FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.support_sessions
            WHERE id = support_messages.session_id AND user_id = auth.uid()
        )
    );

-- =============================================
-- 7. Admin Bypass Policies for Existing Tables
-- =============================================

-- Note: We need to handle existing policies. Using DO block to check if policies exist.

-- Admins can view all profiles
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'profiles' AND policyname = 'Admins can view all profiles'
    ) THEN
        CREATE POLICY "Admins can view all profiles"
            ON public.profiles FOR SELECT
            USING (
                auth.uid() = id OR
                EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = auth.uid() AND p.is_admin = true)
            );
    END IF;
END $$;

-- Admins can view all trips
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'trips' AND policyname = 'Admins can view all trips'
    ) THEN
        CREATE POLICY "Admins can view all trips"
            ON public.trips FOR SELECT
            USING (
                EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
            );
    END IF;
END $$;

-- Admins can view all expenses
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'expenses' AND policyname = 'Admins can view all expenses'
    ) THEN
        CREATE POLICY "Admins can view all expenses"
            ON public.expenses FOR SELECT
            USING (
                EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
            );
    END IF;
END $$;

-- Admins can view all chat sessions
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'chat_sessions' AND policyname = 'Admins can view all chat sessions'
    ) THEN
        CREATE POLICY "Admins can view all chat sessions"
            ON public.chat_sessions FOR SELECT
            USING (
                EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
            );
    END IF;
END $$;

-- Admins can manage all token usage
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'daily_token_usage' AND policyname = 'Admins can manage all token usage'
    ) THEN
        CREATE POLICY "Admins can manage all token usage"
            ON public.daily_token_usage FOR ALL
            USING (
                user_id = auth.uid() OR
                EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
            );
    END IF;
END $$;

-- Admins can view all user settings
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE tablename = 'user_settings' AND policyname = 'Admins can view all user settings'
    ) THEN
        CREATE POLICY "Admins can view all user settings"
            ON public.user_settings FOR SELECT
            USING (
                EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
            );
    END IF;
END $$;

-- =============================================
-- 8. Triggers for Auto-updating Timestamps
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_support_session_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for support_sessions updated_at
DROP TRIGGER IF EXISTS trigger_support_sessions_updated_at ON public.support_sessions;
CREATE TRIGGER trigger_support_sessions_updated_at
    BEFORE UPDATE ON public.support_sessions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_support_session_timestamp();

-- Function to update session on new message
CREATE OR REPLACE FUNCTION public.update_session_on_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.support_sessions
    SET
        last_message_at = NEW.created_at,
        updated_at = NOW(),
        unread_admin_count = CASE
            WHEN NEW.sender_role = 'user' THEN unread_admin_count + 1
            ELSE unread_admin_count
        END,
        unread_user_count = CASE
            WHEN NEW.sender_role = 'admin' THEN unread_user_count + 1
            ELSE unread_user_count
        END
    WHERE id = NEW.session_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for updating session on new message
DROP TRIGGER IF EXISTS trigger_update_session_on_message ON public.support_messages;
CREATE TRIGGER trigger_update_session_on_message
    AFTER INSERT ON public.support_messages
    FOR EACH ROW
    EXECUTE FUNCTION public.update_session_on_message();

-- =============================================
-- 9. Helper Functions for Admin
-- =============================================

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = user_uuid AND is_admin = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get system stats (for admin dashboard)
CREATE OR REPLACE FUNCTION public.get_admin_system_stats()
RETURNS JSON AS $$
DECLARE
    stats JSON;
BEGIN
    -- Check if caller is admin
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

-- Function to reset user token usage (admin only)
CREATE OR REPLACE FUNCTION public.admin_reset_user_tokens(target_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if caller is admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    -- Delete today's token usage for the user
    DELETE FROM public.daily_token_usage
    WHERE user_id = target_user_id AND usage_date = CURRENT_DATE;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user plan type (admin only)
CREATE OR REPLACE FUNCTION public.admin_update_user_plan(target_user_id UUID, new_plan TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if caller is admin
    IF NOT public.is_admin() THEN
        RAISE EXCEPTION 'Unauthorized: Admin access required';
    END IF;

    -- Validate plan type
    IF new_plan NOT IN ('free', 'subscription') THEN
        RAISE EXCEPTION 'Invalid plan type. Must be free or subscription';
    END IF;

    -- Update the plan
    UPDATE public.profiles
    SET plan_type = new_plan, updated_at = NOW()
    WHERE id = target_user_id;

    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark support messages as read
CREATE OR REPLACE FUNCTION public.mark_support_messages_read(p_session_id UUID, p_role TEXT)
RETURNS VOID AS $$
BEGIN
    -- Update messages based on role
    IF p_role = 'admin' THEN
        UPDATE public.support_messages
        SET is_read = true
        WHERE session_id = p_session_id AND sender_role = 'user' AND is_read = false;

        UPDATE public.support_sessions
        SET unread_admin_count = 0
        WHERE id = p_session_id;
    ELSE
        UPDATE public.support_messages
        SET is_read = true
        WHERE session_id = p_session_id AND sender_role = 'admin' AND is_read = false;

        UPDATE public.support_sessions
        SET unread_user_count = 0
        WHERE id = p_session_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 10. Enable Realtime for Support Tables
-- =============================================

-- Enable realtime for support_messages
ALTER PUBLICATION supabase_realtime ADD TABLE public.support_messages;

-- Enable realtime for support_sessions (for status updates)
ALTER PUBLICATION supabase_realtime ADD TABLE public.support_sessions;

-- =============================================
-- 11. Grant Permissions
-- =============================================

GRANT ALL ON public.support_sessions TO authenticated;
GRANT ALL ON public.support_messages TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_system_stats TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_reset_user_tokens TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_user_plan TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_support_messages_read TO authenticated;
