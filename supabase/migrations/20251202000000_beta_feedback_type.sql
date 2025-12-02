-- Migration: Add feedback_type to support_sessions for beta feedback categorization
-- This allows users to categorize their feedback as bug reports, feature requests, or UX feedback

-- Add feedback_type column to support_sessions
ALTER TABLE public.support_sessions
ADD COLUMN IF NOT EXISTS feedback_type TEXT DEFAULT 'general_support';

-- Add check constraint for valid feedback types
ALTER TABLE public.support_sessions
ADD CONSTRAINT support_sessions_feedback_type_check
CHECK (feedback_type IN ('bug_report', 'feature_request', 'ux_feedback', 'general_support'));

-- Create index for filtering by feedback type
CREATE INDEX IF NOT EXISTS idx_support_sessions_feedback_type
ON public.support_sessions(feedback_type);

-- Comment for documentation
COMMENT ON COLUMN public.support_sessions.feedback_type IS 'Type of feedback: bug_report, feature_request, ux_feedback, or general_support';
