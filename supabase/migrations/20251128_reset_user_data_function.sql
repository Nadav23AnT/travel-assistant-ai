-- Create a function to reset user data that bypasses RLS
-- SECURITY DEFINER means this function runs with owner privileges, bypassing RLS
CREATE OR REPLACE FUNCTION reset_user_data(p_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Verify the caller is the same user (security check)
  IF auth.uid() != p_user_id THEN
    RAISE EXCEPTION 'Not authorized to reset this user data';
  END IF;

  -- Delete trips owned by the user (bypasses RLS due to SECURITY DEFINER)
  DELETE FROM trips WHERE owner_id = p_user_id;

  -- Delete onboarding trips
  DELETE FROM onboarding_trips WHERE user_id = p_user_id;

  -- Reset user settings
  UPDATE user_settings
  SET onboarding_completed = false,
      onboarding_completed_at = NULL
  WHERE user_id = p_user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION reset_user_data(UUID) TO authenticated;
