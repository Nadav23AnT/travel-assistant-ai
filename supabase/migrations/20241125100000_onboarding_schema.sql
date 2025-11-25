-- TripBuddy Onboarding Schema
-- Migration: Add onboarding preferences and initial trip setup

-- ============================================
-- PART 1: ADD ONBOARDING COLUMNS TO USER_SETTINGS
-- ============================================

ALTER TABLE public.user_settings
ADD COLUMN IF NOT EXISTS preferred_languages TEXT[] DEFAULT ARRAY['en'],
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMPTZ;

-- ============================================
-- PART 2: CREATE ONBOARDING_TRIPS TABLE
-- ============================================

CREATE TABLE IF NOT EXISTS public.onboarding_trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    destination TEXT,
    destination_place_id TEXT,
    destination_lat DECIMAL(10, 8),
    destination_lng DECIMAL(11, 8),
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_onboarding_trips_user ON public.onboarding_trips(user_id);

-- ============================================
-- PART 3: ENABLE RLS
-- ============================================

ALTER TABLE public.onboarding_trips ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PART 4: CREATE RLS POLICIES
-- ============================================

CREATE POLICY "Users can manage own onboarding trip" ON public.onboarding_trips
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- PART 5: ADD UPDATED_AT TRIGGER
-- ============================================

CREATE TRIGGER update_onboarding_trips_updated_at BEFORE UPDATE ON public.onboarding_trips
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- PART 6: CREATE FUNCTION TO AUTO-CREATE USER_SETTINGS
-- ============================================

-- Update the handle_new_user function to also create user_settings
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Create profile
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');

    -- Create user settings with defaults
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
