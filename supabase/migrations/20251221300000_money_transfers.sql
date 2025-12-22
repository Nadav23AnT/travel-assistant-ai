-- ============================================
-- Money Transfers for Expense Splitting
-- Allows users to record money sent between each other
-- to settle debts without creating new expenses
-- ============================================

-- Create money_transfers table
CREATE TABLE IF NOT EXISTS public.money_transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    from_user_id UUID NOT NULL REFERENCES public.profiles(id),
    to_user_id UUID NOT NULL REFERENCES public.profiles(id),
    amount DECIMAL(12, 2) NOT NULL CHECK (amount > 0),
    currency TEXT NOT NULL DEFAULT 'USD',
    notes TEXT,
    transfer_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID NOT NULL REFERENCES public.profiles(id),

    CONSTRAINT different_users CHECK (from_user_id != to_user_id)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_money_transfers_trip ON public.money_transfers(trip_id);
CREATE INDEX IF NOT EXISTS idx_money_transfers_from ON public.money_transfers(from_user_id);
CREATE INDEX IF NOT EXISTS idx_money_transfers_to ON public.money_transfers(to_user_id);

-- Enable RLS
ALTER TABLE public.money_transfers ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Trip members can view transfers
CREATE POLICY "Trip members can view transfers" ON public.money_transfers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = money_transfers.trip_id
            AND (t.owner_id = auth.uid() OR (tm.user_id = auth.uid() AND tm.status = 'accepted'))
        )
    );

-- RLS Policies: Trip members can create transfers
CREATE POLICY "Trip members can create transfers" ON public.money_transfers
    FOR INSERT WITH CHECK (
        auth.uid() = created_by AND
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = money_transfers.trip_id
            AND (t.owner_id = auth.uid() OR (tm.user_id = auth.uid() AND tm.status = 'accepted'))
        )
    );

-- RLS Policies: Only creator can delete transfers
CREATE POLICY "Creator can delete transfers" ON public.money_transfers
    FOR DELETE USING (auth.uid() = created_by);

-- ============================================
-- Update get_trip_balances() to include transfers
-- ============================================
CREATE OR REPLACE FUNCTION public.get_trip_balances(p_trip_id UUID)
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    avatar_url TEXT,
    total_paid DECIMAL,
    total_owed DECIMAL,
    transfers_sent DECIMAL,
    transfers_received DECIMAL,
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
    ),
    sent AS (
        SELECT mt.from_user_id, COALESCE(SUM(mt.amount), 0) as total
        FROM public.money_transfers mt
        WHERE mt.trip_id = p_trip_id
        GROUP BY mt.from_user_id
    ),
    received AS (
        SELECT mt.to_user_id, COALESCE(SUM(mt.amount), 0) as total
        FROM public.money_transfers mt
        WHERE mt.trip_id = p_trip_id
        GROUP BY mt.to_user_id
    ),
    -- Get all trip members (owner + accepted members)
    trip_users AS (
        SELECT t.owner_id as uid FROM public.trips t WHERE t.id = p_trip_id
        UNION
        SELECT tm.user_id as uid FROM public.trip_members tm
        WHERE tm.trip_id = p_trip_id AND tm.status = 'accepted'
    )
    SELECT
        p.id as user_id,
        p.full_name as user_name,
        p.avatar_url,
        COALESCE(paid.total, 0)::DECIMAL as total_paid,
        COALESCE(owed.total, 0)::DECIMAL as total_owed,
        COALESCE(sent.total, 0)::DECIMAL as transfers_sent,
        COALESCE(received.total, 0)::DECIMAL as transfers_received,
        ((COALESCE(paid.total, 0) + COALESCE(sent.total, 0)) -
         (COALESCE(owed.total, 0) + COALESCE(received.total, 0)))::DECIMAL as balance
    FROM trip_users tu
    JOIN public.profiles p ON p.id = tu.uid
    LEFT JOIN paid ON paid.paid_by = p.id
    LEFT JOIN owed ON owed.user_id = p.id
    LEFT JOIN sent ON sent.from_user_id = p.id
    LEFT JOIN received ON received.to_user_id = p.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ============================================
-- Function to get trip transfers
-- ============================================
CREATE OR REPLACE FUNCTION public.get_trip_transfers(p_trip_id UUID)
RETURNS TABLE (
    id UUID,
    trip_id UUID,
    from_user_id UUID,
    from_user_name TEXT,
    from_avatar_url TEXT,
    to_user_id UUID,
    to_user_name TEXT,
    to_avatar_url TEXT,
    amount DECIMAL,
    currency TEXT,
    notes TEXT,
    transfer_date DATE,
    created_at TIMESTAMPTZ,
    created_by UUID
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        mt.id,
        mt.trip_id,
        mt.from_user_id,
        pf.full_name as from_user_name,
        pf.avatar_url as from_avatar_url,
        mt.to_user_id,
        pt.full_name as to_user_name,
        pt.avatar_url as to_avatar_url,
        mt.amount,
        mt.currency,
        mt.notes,
        mt.transfer_date,
        mt.created_at,
        mt.created_by
    FROM public.money_transfers mt
    JOIN public.profiles pf ON pf.id = mt.from_user_id
    JOIN public.profiles pt ON pt.id = mt.to_user_id
    WHERE mt.trip_id = p_trip_id
    ORDER BY mt.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
