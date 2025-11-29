-- Referral System Migration
-- Allows users to invite friends and earn credits when they sign up

-- Add referral code column to profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS referral_code TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS referred_by UUID REFERENCES public.profiles(id),
ADD COLUMN IF NOT EXISTS referral_credits_earned INTEGER DEFAULT 0;

-- Create referrals tracking table
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

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_referrals_referrer ON public.referrals(referrer_id);
CREATE INDEX IF NOT EXISTS idx_referrals_code ON public.referrals(referral_code);
CREATE INDEX IF NOT EXISTS idx_profiles_referral_code ON public.profiles(referral_code);

-- Enable RLS
ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

-- Users can view their own referrals (as referrer)
CREATE POLICY "Users can view own referrals" ON public.referrals
    FOR SELECT USING (auth.uid() = referrer_id OR auth.uid() = referred_id);

-- Function to generate a unique referral code
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- Excluding confusing chars (0,O,1,I)
    code TEXT := '';
    i INTEGER;
BEGIN
    FOR i IN 1..8 LOOP
        code := code || substr(chars, floor(random() * length(chars) + 1)::int, 1);
    END LOOP;
    RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to ensure user has a referral code (called on profile access)
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

        -- Try to update the profile with the new code
        BEGIN
            UPDATE public.profiles
            SET referral_code = new_code
            WHERE id = p_user_id AND referral_code IS NULL;

            IF FOUND THEN
                RETURN new_code;
            END IF;
        EXCEPTION WHEN unique_violation THEN
            -- Code already exists, try again
            IF attempt >= max_attempts THEN
                RAISE EXCEPTION 'Could not generate unique referral code after % attempts', max_attempts;
            END IF;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to process a referral (called when user signs up with a code)
CREATE OR REPLACE FUNCTION process_referral(
    p_new_user_id UUID,
    p_referral_code TEXT
)
RETURNS JSONB AS $$
DECLARE
    referrer_id UUID;
    credits_to_award INTEGER := 5000; -- 50 credits = 5000 tokens
    result JSONB;
BEGIN
    -- Find the referrer by code
    SELECT id INTO referrer_id
    FROM public.profiles
    WHERE referral_code = UPPER(p_referral_code);

    IF referrer_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Invalid referral code'
        );
    END IF;

    -- Prevent self-referral
    IF referrer_id = p_new_user_id THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'Cannot use your own referral code'
        );
    END IF;

    -- Check if user was already referred
    IF EXISTS (SELECT 1 FROM public.profiles WHERE id = p_new_user_id AND referred_by IS NOT NULL) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'User already has a referrer'
        );
    END IF;

    -- Update the new user's profile with referrer info
    UPDATE public.profiles
    SET referred_by = referrer_id
    WHERE id = p_new_user_id;

    -- Create the referral record
    INSERT INTO public.referrals (referrer_id, referred_id, referral_code, credits_awarded)
    VALUES (referrer_id, p_new_user_id, UPPER(p_referral_code), credits_to_award);

    -- Award credits to the referrer (add to their daily token allowance)
    -- We add bonus tokens to their current usage (as negative, so they have more room)
    UPDATE public.profiles
    SET referral_credits_earned = COALESCE(referral_credits_earned, 0) + credits_to_award
    WHERE id = referrer_id;

    -- Also give bonus to the referred user (welcome bonus)
    UPDATE public.profiles
    SET referral_credits_earned = COALESCE(referral_credits_earned, 0) + credits_to_award
    WHERE id = p_new_user_id;

    RETURN jsonb_build_object(
        'success', true,
        'referrer_id', referrer_id,
        'credits_awarded', credits_to_award,
        'message', 'Referral processed successfully! Both users received 50 bonus credits.'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get referral stats for a user
CREATE OR REPLACE FUNCTION get_referral_stats(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    stats JSONB;
    referral_count INTEGER;
    total_credits INTEGER;
    user_code TEXT;
BEGIN
    -- Get or create referral code
    SELECT ensure_referral_code(p_user_id) INTO user_code;

    -- Count referrals
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
        'total_credits_earned', total_credits / 100, -- Convert tokens to credits
        'total_tokens_earned', total_credits
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION ensure_referral_code(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION process_referral(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_referral_stats(UUID) TO authenticated;
