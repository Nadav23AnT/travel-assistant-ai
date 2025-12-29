-- Add subject column to chat_sessions for categorizing chats by topic
-- Subject types: day, expense, activity, journal, general

-- Add subject column with default 'general'
ALTER TABLE public.chat_sessions
ADD COLUMN subject TEXT DEFAULT 'general'
CHECK (subject IN ('day', 'expense', 'activity', 'journal', 'general'));

-- Add index for filtering by subject
CREATE INDEX idx_chat_sessions_subject ON public.chat_sessions(subject);

-- Update any existing NULL values to 'general'
UPDATE public.chat_sessions SET subject = 'general' WHERE subject IS NULL;

-- Add comment for documentation
COMMENT ON COLUMN public.chat_sessions.subject IS 'Chat subject type: day (tell about day), expense (track expenses), activity (plan activities), journal (generate journal), general (anything else)';
