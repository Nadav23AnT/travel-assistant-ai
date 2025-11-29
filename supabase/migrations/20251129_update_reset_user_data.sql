-- Update reset_user_data function to include chat data
-- This replaces the previous version to also delete chat sessions and messages

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

  -- Delete chat messages first (foreign key constraint)
  DELETE FROM chat_messages WHERE session_id IN (
    SELECT id FROM chat_sessions WHERE user_id = p_user_id
  );

  -- Delete chat sessions
  DELETE FROM chat_sessions WHERE user_id = p_user_id;

  -- Delete expenses (paid_by is the user column)
  DELETE FROM expenses WHERE paid_by = p_user_id;

  -- Delete journal entries
  DELETE FROM journal_entries WHERE user_id = p_user_id;

  -- Delete trips owned by the user (bypasses RLS due to SECURITY DEFINER)
  DELETE FROM trips WHERE owner_id = p_user_id;

  -- Delete onboarding trips
  DELETE FROM onboarding_trips WHERE user_id = p_user_id;

  -- Reset user settings (only core fields that definitely exist)
  UPDATE user_settings
  SET onboarding_completed = false,
      onboarding_completed_at = NULL
  WHERE user_id = p_user_id;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION reset_user_data(UUID) TO authenticated;
