-- Journal entries table for automatic AI-generated travel journals
CREATE TABLE IF NOT EXISTS public.journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    title TEXT,
    content TEXT NOT NULL,
    ai_generated BOOLEAN DEFAULT true,
    source_data JSONB DEFAULT '{}', -- chat message IDs, expense IDs used to generate
    photos TEXT[] DEFAULT '{}', -- array of photo URLs
    mood TEXT CHECK (mood IN ('excited', 'relaxed', 'tired', 'adventurous', 'inspired', 'grateful', 'reflective')),
    locations TEXT[] DEFAULT '{}', -- places mentioned/visited
    weather TEXT, -- weather that day
    highlights TEXT[] DEFAULT '{}', -- key highlights
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(trip_id, entry_date, user_id)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_journal_entries_trip ON public.journal_entries(trip_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_user ON public.journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_date ON public.journal_entries(entry_date);

-- Enable RLS
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

-- Users can manage their own journal entries
CREATE POLICY "Users can manage own journal entries" ON public.journal_entries
    FOR ALL USING (auth.uid() = user_id);

-- Trip members can view journal entries for trips they're part of
CREATE POLICY "Trip members can view journal entries" ON public.journal_entries
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = journal_entries.trip_id
            AND (t.owner_id = auth.uid() OR tm.user_id = auth.uid())
        )
    );

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_journal_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER journal_entries_updated_at
    BEFORE UPDATE ON public.journal_entries
    FOR EACH ROW
    EXECUTE FUNCTION update_journal_updated_at();
