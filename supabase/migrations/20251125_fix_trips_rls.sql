-- Fix infinite recursion in trips RLS policies
-- Drop all existing policies on trips table
DROP POLICY IF EXISTS "Users can view own trips" ON trips;
DROP POLICY IF EXISTS "Users can insert own trips" ON trips;
DROP POLICY IF EXISTS "Users can update own trips" ON trips;
DROP POLICY IF EXISTS "Users can delete own trips" ON trips;
DROP POLICY IF EXISTS "Enable read access for users" ON trips;
DROP POLICY IF EXISTS "Enable insert for users" ON trips;
DROP POLICY IF EXISTS "Enable update for users" ON trips;
DROP POLICY IF EXISTS "Enable delete for users" ON trips;

-- Make sure RLS is enabled
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;

-- Create simple, non-recursive policies
CREATE POLICY "Users can view own trips" ON trips
FOR SELECT USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert own trips" ON trips
FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own trips" ON trips
FOR UPDATE USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete own trips" ON trips
FOR DELETE USING (auth.uid() = owner_id);

-- Also fix onboarding_trips table
DROP POLICY IF EXISTS "Users can view own onboarding trips" ON onboarding_trips;
DROP POLICY IF EXISTS "Users can insert own onboarding trips" ON onboarding_trips;
DROP POLICY IF EXISTS "Users can update own onboarding trips" ON onboarding_trips;
DROP POLICY IF EXISTS "Users can delete own onboarding trips" ON onboarding_trips;
DROP POLICY IF EXISTS "Enable read access for users" ON onboarding_trips;
DROP POLICY IF EXISTS "Enable insert for users" ON onboarding_trips;
DROP POLICY IF EXISTS "Enable update for users" ON onboarding_trips;
DROP POLICY IF EXISTS "Enable delete for users" ON onboarding_trips;

ALTER TABLE onboarding_trips ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own onboarding trips" ON onboarding_trips
FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own onboarding trips" ON onboarding_trips
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own onboarding trips" ON onboarding_trips
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own onboarding trips" ON onboarding_trips
FOR DELETE USING (auth.uid() = user_id);
