-- =====================================================
-- REFERRAL SYSTEM - Run this in Supabase SQL Editor
-- =====================================================
-- This creates a complete referral system where:
-- 1. Each user gets a unique 8-character referral code
-- 2. When someone signs up with a code, BOTH get 50 credits
-- 3. Users can see their referral stats in the app
-- =====================================================

-- Step 1: Add referral columns to profiles table
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES public.profiles(id),
ADD COLUMN IF NOT EXISTS referral_credits_earned INTEGER DEFAULT 0;

-- Step 2: Create referrals tracking table
CREATE TABLE IF NOT EXISTS public.referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    referred_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    referral_code TEXT NOT NULL,
    credits_awarded INTEGER DEFAULT 5000, -- 50 credits = 5000 tokens
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(referred_id) -- Each user can only be referred once
);

-- Step 3: Create indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON public.referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_code ON public.referrals(referral_code);
CREATE INDEX IF NOT EXISTS idx_profiles_referral_code ON public.profiles(referral_code);

-- Step 4: Enable Row Level Security
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

-- Step 5: Create RLS policy (drop if exists first)
DROP POLICY IF EXISTS "Users can view own referrals" ON public.referrals;
CREATE POLICY "Users can view own referrals" ON public.referrals
    FOR SELECT USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

-- Step 6: Function to generate a unique referral code
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- No confusing chars (0,O,1,I)
    code TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..8 LOOP
        code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    END LOOP;
    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Function to ensure user has a referral code
CREATE OR REPLACE FUNCTION ensure_referral_code(p_user_id UUID)
RETURNS TEXT AS $$
DECLARE
    existing_code TEXT;
    new_code TEXT;
    max_attempts INTEGER := 10;
    attempt INTEGER := 0;
BEGIN
    -- Check if user already has a code
    SELECT referral_code INTO existing_code
    FROM public.profiles
    WHERE id = p_user_id;

    IF existing_code IS NOT NULL THEN
        RETURN existing_code;
    END IF;

    -- Generate a unique code
    LOOP
        new_code := generate_referral_code();
        attempt := attempt + 1;

        BEGIN
            UPDATE public.profiles
            SET referral_code = new_code
            WHERE id = p_user_id AND referral_code IS NULL;

            IF FOUND THEN
                RETURN new_code;
            END IF;
        EXCEPTION WHEN unique_violation THEN
            IF attempt >= max_attempts THEN
                RAISE EXCEPTION 'Could not generate unique referral code';
            END IF;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 8: Function to process a referral (awards 50 credits to BOTH users)
CREATE OR REPLACE FUNCTION process_referral(
    p_new_user_id UUID,
    p_referral_code TEXT
)
RETURNS JSONB AS $$
DECLARE
    referrer_id UUID;
    credits_to_award INTEGER := 5000; -- 50 credits = 5000 tokens
BEGIN
    -- Find the referrer by code
    SELECT id INTO referrer_id
    FROM public.profiles
    WHERE referral_code = UPPER(p_referral_code);

    IF referrer_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid referral code');
    END IF;

    -- Prevent self-referral
    IF referrer_id = p_new_user_id THEN
        RETURN jsonb_build_object('success', false, 'error', 'Cannot use your own referral code');
    END IF;

    -- Check if already referred
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = p_new_user_id AND referred_by IS NOT NULL) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Already has a referrer');
    END IF;

    -- Link the new user to the referrer
    UPDATE public.profiles SET referred_by = referrer_id WHERE id = p_new_user_id;

    -- Create the referral record
    INSERT INTO public.referrals (referrer_id, referred_id, referral_code, credits_awarded)
    VALUES (referrer_id, p_new_user_id, UPPER(p_referral_code), credits_to_award);

    -- Award credits to the REFERRER
    UPDATE public.profiles
    SET referral_credits_earned = COALESCE(referral_credits_earned, 0) + credits_to_award
    WHERE id = referrer_id;

    -- Award credits to the NEW USER (welcome bonus)
    UPDATE public.profiles
    SET referral_credits_earned = COALESCE(referral_credits_earned, 0) + credits_to_award
    WHERE id = p_new_user_id;

    RETURN jsonb_build_object(
        'success', true,
        'referrer_id', referrer_id,
        'credits_awarded', credits_to_award,
        'message', 'Both users received 50 bonus credits!'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 9: Function to get referral stats for a user
CREATE OR REPLACE FUNCTION get_referral_stats(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    referral_count INTEGER;
    total_credits INTEGER;
    user_code TEXT;
BEGIN
    -- Get or create referral code
    SELECT ensure_referral_code(p_user_id) INTO user_code;

    -- Count completed referrals
    SELECT COUNT(*) INTO referral_count
    FROM public.referrals
    WHERE referrer_id = p_user_id AND status = 'completed';

    -- Get total credits earned
    SELECT COALESCE(referral_credits_earned, 0) INTO total_credits
    FROM public.profiles
    WHERE id = p_user_id;

    RETURN jsonb_build_object(
        'referral_code', user_code,
        'referral_count', referral_count,
        'total_credits_earned', total_credits / 100,
        'total_tokens_earned', total_credits
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 10: Grant permissions to authenticated users
GRANT EXECUTE ON FUNCTION ensure_referral_code(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION process_referral(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_referral_stats(UUID) TO authenticated;

-- =====================================================
-- DONE! The referral system is now active.
-- =====================================================
-- How it works:
-- 1. Users see their code in Profile > "Invite Friends"
-- 2. They share the code with friends
-- 3. Friend enters code during signup
-- 4. BOTH get 50 credits (5000 tokens)
-- =====================================================
