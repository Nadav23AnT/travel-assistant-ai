-- =====================================================
-- TRIP SHARING SYSTEM - Collaborative Trip Planning
-- =====================================================
-- This adds invite codes to trips so users can share trips
-- with friends. Shared members get full edit access.
-- =====================================================

-- Step 1: Add invite_code column to trips table
ALTER TABLE public.trips ADD COLUMN IF NOT EXISTS invite_code TEXT UNIQUE;

-- Step 2: Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_trips_invite_code ON public.trips(invite_code);

-- Step 3: Function to generate a unique trip invite code
CREATE OR REPLACE FUNCTION generate_trip_invite_code()
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

-- Step 4: Function to ensure trip has an invite code (get or create)
CREATE OR REPLACE FUNCTION ensure_trip_invite_code(p_trip_id UUID)
RETURNS TEXT AS $$
DECLARE
    existing_code TEXT;
    new_code TEXT;
    max_attempts INTEGER := 10;
    attempt INTEGER := 0;
BEGIN
    -- Check if trip already has a code
    SELECT invite_code INTO existing_code
    FROM public.trips
    WHERE id = p_trip_id;

    IF existing_code IS NOT NULL THEN
        RETURN existing_code;
    END IF;

    -- Generate a unique code
    LOOP
        new_code := generate_trip_invite_code();
        attempt := attempt + 1;

        BEGIN
            UPDATE public.trips
            SET invite_code = new_code
            WHERE id = p_trip_id AND invite_code IS NULL;

            IF FOUND THEN
                RETURN new_code;
            END IF;
        EXCEPTION WHEN unique_violation THEN
            IF attempt >= max_attempts THEN
                RAISE EXCEPTION 'Could not generate unique trip invite code';
            END IF;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 5: Function to join a trip using invite code
CREATE OR REPLACE FUNCTION join_trip_by_code(p_user_id UUID, p_invite_code TEXT)
RETURNS JSONB AS $$
DECLARE
    v_trip_id UUID;
    v_owner_id UUID;
    v_trip_title TEXT;
BEGIN
    -- Find trip by code (case-insensitive)
    SELECT id, owner_id, title INTO v_trip_id, v_owner_id, v_trip_title
    FROM public.trips
    WHERE invite_code = UPPER(TRIM(p_invite_code));

    IF v_trip_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid invite code');
    END IF;

    -- Prevent owner from joining own trip
    IF v_owner_id = p_user_id THEN
        RETURN jsonb_build_object('success', false, 'error', 'You are the owner of this trip');
    END IF;

    -- Check if already a member
    IF EXISTS (SELECT 1 FROM public.trip_members WHERE trip_id = v_trip_id AND user_id = p_user_id) THEN
        RETURN jsonb_build_object('success', false, 'error', 'Already a member of this trip');
    END IF;

    -- Add as member with editor role (full access)
    INSERT INTO public.trip_members (id, trip_id, user_id, role, invited_by, status, joined_at)
    VALUES (gen_random_uuid(), v_trip_id, p_user_id, 'editor', v_owner_id, 'accepted', NOW());

    RETURN jsonb_build_object(
        'success', true,
        'trip_id', v_trip_id,
        'trip_title', v_trip_title,
        'message', 'Successfully joined trip!'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 6: Function to get trip members with profile info
CREATE OR REPLACE FUNCTION get_trip_members(p_trip_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_owner_id UUID;
    v_members JSONB;
BEGIN
    -- Get owner ID
    SELECT owner_id INTO v_owner_id FROM public.trips WHERE id = p_trip_id;

    -- Get all members including owner
    SELECT jsonb_agg(member_data ORDER BY is_owner DESC, joined_at ASC)
    INTO v_members
    FROM (
        -- Owner (always first)
        SELECT
            NULL::UUID as id,
            p.id as user_id,
            'owner' as role,
            'accepted' as status,
            t.created_at as joined_at,
            p.full_name,
            p.avatar_url,
            p.email,
            true as is_owner
        FROM public.trips t
        JOIN public.profiles p ON p.id = t.owner_id
        WHERE t.id = p_trip_id

        UNION ALL

        -- Other members
        SELECT
            tm.id,
            tm.user_id,
            tm.role,
            tm.status,
            tm.joined_at,
            p.full_name,
            p.avatar_url,
            p.email,
            false as is_owner
        FROM public.trip_members tm
        JOIN public.profiles p ON p.id = tm.user_id
        WHERE tm.trip_id = p_trip_id AND tm.status = 'accepted'
    ) member_data;

    RETURN COALESCE(v_members, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 7: Function to leave a trip (for non-owners)
CREATE OR REPLACE FUNCTION leave_trip(p_user_id UUID, p_trip_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_owner_id UUID;
BEGIN
    -- Check if user is the owner
    SELECT owner_id INTO v_owner_id FROM public.trips WHERE id = p_trip_id;

    IF v_owner_id = p_user_id THEN
        RETURN jsonb_build_object('success', false, 'error', 'Owner cannot leave the trip. Delete it instead.');
    END IF;

    -- Remove membership
    DELETE FROM public.trip_members
    WHERE trip_id = p_trip_id AND user_id = p_user_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'You are not a member of this trip');
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Left trip successfully');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 8: Function to remove a member (owner only)
CREATE OR REPLACE FUNCTION remove_trip_member(p_owner_id UUID, p_trip_id UUID, p_member_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    v_actual_owner_id UUID;
BEGIN
    -- Verify the caller is the owner
    SELECT owner_id INTO v_actual_owner_id FROM public.trips WHERE id = p_trip_id;

    IF v_actual_owner_id != p_owner_id THEN
        RETURN jsonb_build_object('success', false, 'error', 'Only the owner can remove members');
    END IF;

    -- Cannot remove owner
    IF v_actual_owner_id = p_member_user_id THEN
        RETURN jsonb_build_object('success', false, 'error', 'Cannot remove the owner');
    END IF;

    -- Remove membership
    DELETE FROM public.trip_members
    WHERE trip_id = p_trip_id AND user_id = p_member_user_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'User is not a member of this trip');
    END IF;

    RETURN jsonb_build_object('success', true, 'message', 'Member removed successfully');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 9: Function to get all user trips (owned + shared)
CREATE OR REPLACE FUNCTION get_user_all_trips(p_user_id UUID)
RETURNS JSONB AS $$
BEGIN
    RETURN (
        SELECT jsonb_agg(trip_data ORDER BY start_date ASC NULLS LAST)
        FROM (
            -- Owned trips
            SELECT
                t.*,
                true as is_owner
            FROM public.trips t
            WHERE t.owner_id = p_user_id

            UNION ALL

            -- Shared trips (member but not owner)
            SELECT
                t.*,
                false as is_owner
            FROM public.trips t
            INNER JOIN public.trip_members tm ON tm.trip_id = t.id
            WHERE tm.user_id = p_user_id
              AND tm.status = 'accepted'
              AND t.owner_id != p_user_id
        ) trip_data
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 10: Grant permissions to authenticated users
GRANT EXECUTE ON FUNCTION ensure_trip_invite_code(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION join_trip_by_code(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION get_trip_members(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION leave_trip(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION remove_trip_member(UUID, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_all_trips(UUID) TO authenticated;

-- =====================================================
-- DONE! The trip sharing system is now active.
-- =====================================================
-- How it works:
-- 1. Owner opens trip → gets/generates invite code
-- 2. Owner shares code with friends
-- 3. Friend enters code → joins as editor with full access
-- 4. All members can view/edit expenses, itinerary, journal
-- =====================================================
