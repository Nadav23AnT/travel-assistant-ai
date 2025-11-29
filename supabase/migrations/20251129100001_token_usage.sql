-- Token Usage Tracking Migration
-- Tracks daily AI token usage per user with automatic date-based reset

-- ============================================
-- PART 1: CREATE TOKEN USAGE TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.daily_token_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    usage_date DATE NOT NULL DEFAULT CURRENT_DATE,
    tokens_used INTEGER NOT NULL DEFAULT 0,
    request_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, usage_date)
);

CREATE INDEX IF NOT EXISTS idx_daily_token_usage_user ON public.daily_token_usage(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_token_usage_date ON public.daily_token_usage(usage_date);
CREATE INDEX IF NOT EXISTS idx_daily_token_usage_user_date ON public.daily_token_usage(user_id, usage_date);

-- ============================================
-- PART 2: ADD PLAN TYPE TO PROFILES
-- ============================================

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS plan_type TEXT DEFAULT 'free'
CHECK (plan_type IN ('free', 'subscription'));

-- ============================================
-- PART 3: ENABLE RLS
-- ============================================

ALTER TABLE public.daily_token_usage ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PART 4: CREATE RLS POLICIES
-- ============================================

CREATE POLICY "Users can view own token usage" ON public.daily_token_usage
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own token usage" ON public.daily_token_usage
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own token usage" ON public.daily_token_usage
    FOR UPDATE USING (auth.uid() = user_id);

-- ============================================
-- PART 5: ADD UPDATED_AT TRIGGER
-- ============================================

CREATE TRIGGER update_daily_token_usage_updated_at
    BEFORE UPDATE ON public.daily_token_usage
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- PART 6: FUNCTION TO GET OR CREATE TODAY'S USAGE
-- ============================================

CREATE OR REPLACE FUNCTION get_or_create_daily_usage(p_user_id UUID)
RETURNS TABLE (
    tokens_used INTEGER,
    request_count INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_tokens INTEGER;
    v_requests INTEGER;
BEGIN
    -- Try to get existing record for today
    SELECT dtu.tokens_used, dtu.request_count
    INTO v_tokens, v_requests
    FROM daily_token_usage dtu
    WHERE dtu.user_id = p_user_id AND dtu.usage_date = CURRENT_DATE;

    -- If no record exists, create one
    IF NOT FOUND THEN
        INSERT INTO daily_token_usage (user_id, usage_date, tokens_used, request_count)
        VALUES (p_user_id, CURRENT_DATE, 0, 0)
        ON CONFLICT (user_id, usage_date) DO NOTHING;

        v_tokens := 0;
        v_requests := 0;
    END IF;

    RETURN QUERY SELECT v_tokens, v_requests;
END;
$$;

GRANT EXECUTE ON FUNCTION get_or_create_daily_usage(UUID) TO authenticated;

-- ============================================
-- PART 7: FUNCTION TO INCREMENT TOKEN USAGE
-- ============================================

CREATE OR REPLACE FUNCTION increment_token_usage(
    p_user_id UUID,
    p_tokens INTEGER
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO daily_token_usage (user_id, usage_date, tokens_used, request_count)
    VALUES (p_user_id, CURRENT_DATE, p_tokens, 1)
    ON CONFLICT (user_id, usage_date)
    DO UPDATE SET
        tokens_used = daily_token_usage.tokens_used + p_tokens,
        request_count = daily_token_usage.request_count + 1,
        updated_at = NOW();
END;
$$;

GRANT EXECUTE ON FUNCTION increment_token_usage(UUID, INTEGER) TO authenticated;

-- ============================================
-- PART 8: FUNCTION TO CHECK TOKEN LIMIT
-- ============================================

CREATE OR REPLACE FUNCTION check_token_limit(
    p_user_id UUID,
    p_free_limit INTEGER,
    p_subscription_limit INTEGER
)
RETURNS TABLE (
    allowed BOOLEAN,
    tokens_used INTEGER,
    daily_limit INTEGER,
    tokens_remaining INTEGER,
    plan_type TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_plan_type TEXT;
    v_tokens_used INTEGER;
    v_daily_limit INTEGER;
BEGIN
    -- Get user's plan type
    SELECT p.plan_type INTO v_plan_type
    FROM profiles p
    WHERE p.id = p_user_id;

    IF v_plan_type IS NULL THEN
        v_plan_type := 'free';
    END IF;

    -- Determine daily limit based on plan
    IF v_plan_type = 'subscription' THEN
        v_daily_limit := p_subscription_limit;
    ELSE
        v_daily_limit := p_free_limit;
    END IF;

    -- Get today's usage
    SELECT COALESCE(dtu.tokens_used, 0) INTO v_tokens_used
    FROM daily_token_usage dtu
    WHERE dtu.user_id = p_user_id AND dtu.usage_date = CURRENT_DATE;

    IF v_tokens_used IS NULL THEN
        v_tokens_used := 0;
    END IF;

    RETURN QUERY SELECT
        v_tokens_used < v_daily_limit AS allowed,
        v_tokens_used AS tokens_used,
        v_daily_limit AS daily_limit,
        GREATEST(0, v_daily_limit - v_tokens_used) AS tokens_remaining,
        v_plan_type AS plan_type;
END;
$$;

GRANT EXECUTE ON FUNCTION check_token_limit(UUID, INTEGER, INTEGER) TO authenticated;
