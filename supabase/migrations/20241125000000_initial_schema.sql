-- TripBuddy Database Schema
-- Initial migration: All tables with RLS policies

-- ============================================
-- PART 1: CREATE ALL TABLES FIRST
-- ============================================

-- 1. PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    default_currency TEXT DEFAULT 'USD',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. USER SETTINGS TABLE
CREATE TABLE IF NOT EXISTS public.user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    ai_provider TEXT DEFAULT 'openai' CHECK (ai_provider IN ('openai', 'openrouter', 'gemini')),
    ai_model TEXT DEFAULT 'gpt-4',
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 3. SUBSCRIPTIONS TABLE
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'premium', 'premium_annual')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'canceled', 'expired')),
    provider TEXT,
    provider_subscription_id TEXT,
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 4. TRIPS TABLE
CREATE TABLE IF NOT EXISTS public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    destination TEXT NOT NULL,
    destination_place_id TEXT,
    destination_lat DECIMAL(10, 8),
    destination_lng DECIMAL(11, 8),
    cover_image_url TEXT,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12, 2),
    budget_currency TEXT DEFAULT 'USD',
    description TEXT,
    status TEXT DEFAULT 'planning' CHECK (status IN ('planning', 'active', 'completed', 'canceled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_trips_owner ON public.trips(owner_id);
CREATE INDEX idx_trips_status ON public.trips(status);
CREATE INDEX idx_trips_dates ON public.trips(start_date, end_date);

-- 5. TRIP MEMBERS TABLE
CREATE TABLE IF NOT EXISTS public.trip_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'viewer' CHECK (role IN ('owner', 'editor', 'viewer')),
    invited_by UUID REFERENCES public.profiles(id),
    invited_at TIMESTAMPTZ DEFAULT NOW(),
    joined_at TIMESTAMPTZ,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(trip_id, user_id)
);

CREATE INDEX idx_trip_members_trip ON public.trip_members(trip_id);
CREATE INDEX idx_trip_members_user ON public.trip_members(user_id);

-- 6. ITINERARY ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.itinerary_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES public.profiles(id),
    day_number INTEGER NOT NULL,
    order_index INTEGER NOT NULL DEFAULT 0,
    title TEXT NOT NULL,
    description TEXT,
    place_name TEXT,
    place_id TEXT,
    place_lat DECIMAL(10, 8),
    place_lng DECIMAL(11, 8),
    place_address TEXT,
    start_time TIME,
    end_time TIME,
    category TEXT CHECK (category IN ('accommodation', 'transport', 'food', 'activity', 'attraction', 'other')),
    estimated_cost DECIMAL(10, 2),
    cost_currency TEXT DEFAULT 'USD',
    notes TEXT,
    is_ai_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_itinerary_trip ON public.itinerary_items(trip_id);
CREATE INDEX idx_itinerary_day ON public.itinerary_items(trip_id, day_number);

-- 7. EXPENSES TABLE
CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    paid_by UUID NOT NULL REFERENCES public.profiles(id),
    amount DECIMAL(12, 2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    category TEXT NOT NULL CHECK (category IN ('transport', 'accommodation', 'food', 'activities', 'shopping', 'other')),
    description TEXT NOT NULL,
    expense_date DATE DEFAULT CURRENT_DATE,
    receipt_url TEXT,
    is_split BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_expenses_trip ON public.expenses(trip_id);
CREATE INDEX idx_expenses_paid_by ON public.expenses(paid_by);
CREATE INDEX idx_expenses_date ON public.expenses(expense_date);
CREATE INDEX idx_expenses_category ON public.expenses(category);

-- 8. EXPENSE SPLITS TABLE
CREATE TABLE IF NOT EXISTS public.expense_splits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id),
    amount DECIMAL(12, 2) NOT NULL,
    is_settled BOOLEAN DEFAULT false,
    settled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(expense_id, user_id)
);

CREATE INDEX idx_splits_expense ON public.expense_splits(expense_id);
CREATE INDEX idx_splits_user ON public.expense_splits(user_id);

-- 9. CHAT SESSIONS TABLE
CREATE TABLE IF NOT EXISTS public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT DEFAULT 'New Chat',
    ai_provider TEXT DEFAULT 'openai',
    ai_model TEXT DEFAULT 'gpt-4',
    context JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_sessions_user ON public.chat_sessions(user_id);
CREATE INDEX idx_chat_sessions_trip ON public.chat_sessions(trip_id);

-- 10. CHAT MESSAGES TABLE
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    tokens_used INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_session ON public.chat_messages(session_id);
CREATE INDEX idx_chat_messages_created ON public.chat_messages(created_at);

-- ============================================
-- PART 2: ENABLE RLS ON ALL TABLES
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itinerary_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_splits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- ============================================
-- PART 3: CREATE ALL RLS POLICIES
-- ============================================

-- PROFILES POLICIES
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- USER SETTINGS POLICIES
CREATE POLICY "Users can manage own settings" ON public.user_settings
    FOR ALL USING (auth.uid() = user_id);

-- SUBSCRIPTIONS POLICIES
CREATE POLICY "Users can view own subscription" ON public.subscriptions
    FOR SELECT USING (auth.uid() = user_id);

-- TRIPS POLICIES
CREATE POLICY "Owners can manage trips" ON public.trips
    FOR ALL USING (auth.uid() = owner_id);

CREATE POLICY "Members can view trips" ON public.trips
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trip_members
            WHERE trip_id = trips.id AND user_id = auth.uid()
        )
    );

-- TRIP MEMBERS POLICIES
CREATE POLICY "Users can view relevant memberships" ON public.trip_members
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM public.trips
            WHERE id = trip_members.trip_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Owners can invite members" ON public.trip_members
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.trips
            WHERE id = trip_members.trip_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own membership" ON public.trip_members
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Owners can delete members" ON public.trip_members
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.trips
            WHERE id = trip_members.trip_id AND owner_id = auth.uid()
        )
    );

-- ITINERARY ITEMS POLICIES
CREATE POLICY "Members can view itinerary" ON public.itinerary_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = itinerary_items.trip_id
            AND (t.owner_id = auth.uid() OR tm.user_id = auth.uid())
        )
    );

CREATE POLICY "Editors can manage itinerary" ON public.itinerary_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = itinerary_items.trip_id
            AND (t.owner_id = auth.uid() OR (tm.user_id = auth.uid() AND tm.role IN ('owner', 'editor')))
        )
    );

-- EXPENSES POLICIES
CREATE POLICY "Members can view expenses" ON public.expenses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = expenses.trip_id
            AND (t.owner_id = auth.uid() OR tm.user_id = auth.uid())
        )
    );

CREATE POLICY "Members can create expenses" ON public.expenses
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = expenses.trip_id
            AND (t.owner_id = auth.uid() OR tm.user_id = auth.uid())
        )
    );

CREATE POLICY "Creators can update expenses" ON public.expenses
    FOR UPDATE USING (auth.uid() = paid_by);

CREATE POLICY "Creators can delete expenses" ON public.expenses
    FOR DELETE USING (auth.uid() = paid_by);

-- EXPENSE SPLITS POLICIES
CREATE POLICY "Users can view their splits" ON public.expense_splits
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM public.expenses e
            WHERE e.id = expense_splits.expense_id AND e.paid_by = auth.uid()
        )
    );

CREATE POLICY "Expense creators can create splits" ON public.expense_splits
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.expenses e
            WHERE e.id = expense_splits.expense_id AND e.paid_by = auth.uid()
        )
    );

CREATE POLICY "Users can update own splits" ON public.expense_splits
    FOR UPDATE USING (auth.uid() = user_id);

-- CHAT SESSIONS POLICIES
CREATE POLICY "Users can manage own chat sessions" ON public.chat_sessions
    FOR ALL USING (auth.uid() = user_id);

-- CHAT MESSAGES POLICIES
CREATE POLICY "Users can manage own messages" ON public.chat_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.chat_sessions
            WHERE id = chat_messages.session_id AND user_id = auth.uid()
        )
    );

-- ============================================
-- PART 4: FUNCTIONS AND TRIGGERS
-- ============================================

-- Trigger to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to get expense balances for a trip
CREATE OR REPLACE FUNCTION public.get_trip_balances(p_trip_id UUID)
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    total_paid DECIMAL,
    total_owed DECIMAL,
    balance DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    WITH paid AS (
        SELECT e.paid_by, COALESCE(SUM(e.amount), 0) as total
        FROM public.expenses e
        WHERE e.trip_id = p_trip_id
        GROUP BY e.paid_by
    ),
    owed AS (
        SELECT es.user_id, COALESCE(SUM(es.amount), 0) as total
        FROM public.expense_splits es
        JOIN public.expenses e ON e.id = es.expense_id
        WHERE e.trip_id = p_trip_id AND NOT es.is_settled
        GROUP BY es.user_id
    )
    SELECT
        p.id as user_id,
        p.full_name as user_name,
        COALESCE(paid.total, 0) as total_paid,
        COALESCE(owed.total, 0) as total_owed,
        COALESCE(paid.total, 0) - COALESCE(owed.total, 0) as balance
    FROM public.profiles p
    JOIN public.trip_members tm ON tm.user_id = p.id
    LEFT JOIN paid ON paid.paid_by = p.id
    LEFT JOIN owed ON owed.user_id = p.id
    WHERE tm.trip_id = p_trip_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to all tables
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON public.user_settings
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_trips_updated_at BEFORE UPDATE ON public.trips
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_itinerary_items_updated_at BEFORE UPDATE ON public.itinerary_items
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_chat_sessions_updated_at BEFORE UPDATE ON public.chat_sessions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
