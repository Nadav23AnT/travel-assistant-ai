# TripBuddy - Architecture & Specification

**Version:** 1.10.0
**Last Updated:** November 29, 2025
**Related:** See `claude.md` for development workflow and coding standards.

---

## 1. App Overview

### What is TripBuddy?

TripBuddy is an AI-powered travel assistant mobile app that combines intelligent trip planning with expense tracking. It helps users plan trips through conversational AI, get personalized recommendations, and manage travel expenses including cost splitting with travel companions.

### Target Users

- **Solo Travelers**: Individual trip planning and personal expense tracking
- **Group Travelers**: Collaborative planning, shared trips, expense splitting
- **Budget-Conscious Travelers**: Users who want to track and optimize travel spending

### Core Value Proposition

1. **AI-First Planning**: Natural conversation-based trip planning instead of manual research
2. **Smart Recommendations**: Personalized suggestions for destinations, activities, and restaurants
3. **Expense Management**: Real-time expense tracking with automatic splitting for group trips
4. **All-in-One Solution**: Trip planning + itinerary + expenses in a single app

---

## 2. Tech Stack

### Frontend
| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform mobile (iOS & Android) |
| **Dart** | Programming language |
| **flutter_bloc / Riverpod** | State management |
| **go_router** | Navigation and routing |
| **flutter_secure_storage** | Secure credential storage |

### Backend
| Technology | Purpose |
|------------|---------|
| **Supabase** | Backend-as-a-Service |
| **PostgreSQL** | Primary database |
| **Supabase Auth** | Authentication (email, social) |
| **Supabase Realtime** | Real-time subscriptions |
| **Supabase Edge Functions** | Serverless functions (Deno) |
| **Supabase Storage** | File storage (receipts, trip photos) |

### AI & APIs
| Service | Purpose |
|---------|---------|
| **OpenAI API** | Primary AI provider (GPT-4) |
| **OpenRouter** | Multi-model access (future) |
| **Google Gemini** | Alternative AI provider (future) |
| **Google Maps SDK** | Map display and navigation |
| **Google Places API** | Location search and recommendations |

### DevOps & Tools
| Tool | Purpose |
|------|---------|
| **GitHub** | Version control |
| **GitHub Actions** | CI/CD pipelines |
| **RevenueCat** | Subscription management |
| **Firebase Crashlytics** | Crash reporting |
| **Sentry** | Error monitoring |

---

## 3. Core Features (MVP)

### 3.1 Authentication
- Email/password registration and login
- Social authentication (Google, Apple)
- Password reset flow
- Session management with JWT

### 3.2 Trip Management
- Create, read, update, delete trips
- Trip details: destination, dates, budget, cover image
- Trip sharing with other users (invite via email/link)
- Member roles: owner, editor, viewer

### 3.3 Itinerary Planning
- Day-by-day activity planning
- Add places with time, location, and notes
- Google Places integration for location search
- Drag-and-drop reordering
- Map view of daily activities

### 3.4 AI Chat Interface
- Conversational trip planning
- Context-aware responses (knows current trip details)
- Recommendation generation for:
  - Destinations and attractions
  - Restaurants and dining
  - Activities and experiences
  - Optimal routes and timing
- Auto-generate itinerary from conversation
- Save recommendations to itinerary

### 3.5 Expense Tracking
- Log expenses with amount, currency, category
- Expense categories: Transport, Accommodation, Food, Activities, Shopping, Other
- Receipt photo capture and storage
- Per-trip expense summaries
- Category breakdown with charts

### 3.6 Expense Splitting (Group Trips)
- Split expenses equally or custom amounts
- Track who paid and who owes
- Running balance per trip member
- Settlement tracking (mark as paid)
- Settlement summary screen

### 3.7 User Profile & Settings
- Profile management (name, avatar)
- AI provider selection (OpenAI / OpenRouter / Gemini)
- Default currency preference
- Notification settings
- Subscription status

---

## 4. Database Schema (Full SQL)

### 4.1 Profiles Table

```sql
-- User profiles (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    default_currency TEXT DEFAULT 'USD',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Trigger to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### 4.2 User Settings Table

```sql
-- User settings and preferences
CREATE TABLE public.user_settings (
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

ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own settings" ON public.user_settings
    FOR ALL USING (auth.uid() = user_id);
```

### 4.3 Subscriptions Table

```sql
-- Subscription/premium status
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'premium', 'premium_annual')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'canceled', 'expired')),
    provider TEXT, -- 'revenuecat', 'stripe', etc.
    provider_subscription_id TEXT,
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription" ON public.subscriptions
    FOR SELECT USING (auth.uid() = user_id);
```

### 4.4 Trips Table

```sql
-- Trip metadata
CREATE TABLE public.trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    destination TEXT NOT NULL,
    destination_place_id TEXT, -- Google Places ID
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

ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;

-- Owner can do everything
CREATE POLICY "Owners can manage trips" ON public.trips
    FOR ALL USING (auth.uid() = owner_id);

-- Members can view trips they're part of
CREATE POLICY "Members can view trips" ON public.trips
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trip_members
            WHERE trip_id = trips.id AND user_id = auth.uid()
        )
    );
```

### 4.5 Trip Members Table

```sql
-- Trip membership (for group trips)
CREATE TABLE public.trip_members (
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

ALTER TABLE public.trip_members ENABLE ROW LEVEL SECURITY;

-- Users can see memberships for their trips or their own memberships
CREATE POLICY "Users can view relevant memberships" ON public.trip_members
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM public.trips
            WHERE id = trip_members.trip_id AND owner_id = auth.uid()
        )
    );

-- Only trip owners can invite members
CREATE POLICY "Owners can invite members" ON public.trip_members
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.trips
            WHERE id = trip_members.trip_id AND owner_id = auth.uid()
        )
    );
```

### 4.6 Itinerary Items Table

```sql
-- Itinerary items (activities, places)
CREATE TABLE public.itinerary_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES public.trips(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES public.profiles(id),
    day_number INTEGER NOT NULL, -- Day 1, 2, 3, etc.
    order_index INTEGER NOT NULL DEFAULT 0,
    title TEXT NOT NULL,
    description TEXT,
    place_name TEXT,
    place_id TEXT, -- Google Places ID
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

ALTER TABLE public.itinerary_items ENABLE ROW LEVEL SECURITY;

-- Trip members can view itinerary
CREATE POLICY "Members can view itinerary" ON public.itinerary_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = itinerary_items.trip_id
            AND (t.owner_id = auth.uid() OR tm.user_id = auth.uid())
        )
    );

-- Owners and editors can modify itinerary
CREATE POLICY "Editors can modify itinerary" ON public.itinerary_items
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = itinerary_items.trip_id
            AND (t.owner_id = auth.uid() OR (tm.user_id = auth.uid() AND tm.role IN ('owner', 'editor')))
        )
    );
```

### 4.7 Expenses Table

```sql
-- Expense records
CREATE TABLE public.expenses (
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

ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Trip members can view and create expenses
CREATE POLICY "Members can manage expenses" ON public.expenses
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.trips t
            LEFT JOIN public.trip_members tm ON t.id = tm.trip_id
            WHERE t.id = expenses.trip_id
            AND (t.owner_id = auth.uid() OR tm.user_id = auth.uid())
        )
    );
```

### 4.8 Expense Splits Table

```sql
-- Expense splits (who owes what)
CREATE TABLE public.expense_splits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id),
    amount DECIMAL(12, 2) NOT NULL, -- Amount this user owes
    is_settled BOOLEAN DEFAULT false,
    settled_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(expense_id, user_id)
);

CREATE INDEX idx_splits_expense ON public.expense_splits(expense_id);
CREATE INDEX idx_splits_user ON public.expense_splits(user_id);

ALTER TABLE public.expense_splits ENABLE ROW LEVEL SECURITY;

-- Users can see splits they're involved in
CREATE POLICY "Users can view their splits" ON public.expense_splits
    FOR SELECT USING (
        auth.uid() = user_id OR
        EXISTS (
            SELECT 1 FROM public.expenses e
            WHERE e.id = expense_splits.expense_id AND e.paid_by = auth.uid()
        )
    );

-- Users can update their own splits (mark as settled)
CREATE POLICY "Users can update own splits" ON public.expense_splits
    FOR UPDATE USING (auth.uid() = user_id);
```

### 4.9 Chat Sessions Table

```sql
-- AI chat sessions (one per trip typically)
CREATE TABLE public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES public.trips(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT DEFAULT 'New Chat',
    ai_provider TEXT DEFAULT 'openai',
    ai_model TEXT DEFAULT 'gpt-4',
    context JSONB DEFAULT '{}', -- Trip context, user preferences, etc.
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_sessions_user ON public.chat_sessions(user_id);
CREATE INDEX idx_chat_sessions_trip ON public.chat_sessions(trip_id);

ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own chat sessions" ON public.chat_sessions
    FOR ALL USING (auth.uid() = user_id);
```

### 4.10 Chat Messages Table

```sql
-- Individual chat messages
CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}', -- For recommendations, actions, etc.
    tokens_used INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_chat_messages_session ON public.chat_messages(session_id);
CREATE INDEX idx_chat_messages_created ON public.chat_messages(created_at);

ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own messages" ON public.chat_messages
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.chat_sessions
            WHERE id = chat_messages.session_id AND user_id = auth.uid()
        )
    );
```

### 4.11 Database Functions

```sql
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
```

---

## 5. AI Provider Architecture

### 5.1 Provider Interface

The app uses a dynamic AI provider system allowing users to switch between providers:

```dart
// lib/services/ai/ai_provider.dart
abstract class AIProvider {
  Future<String> generateResponse(List<ChatMessage> messages, {Map<String, dynamic>? context});
  Future<List<Recommendation>> getRecommendations(String query, {String? location});
  Future<Itinerary> generateItinerary(TripContext context);
  Stream<String> streamResponse(List<ChatMessage> messages);
}
```

### 5.2 Supported Providers

| Provider | Models | Status |
|----------|--------|--------|
| **OpenAI** | GPT-4, GPT-4-turbo, GPT-3.5-turbo | Primary (MVP) |
| **OpenRouter** | Multiple models (Claude, Llama, etc.) | Future |
| **Google Gemini** | Gemini Pro, Gemini Ultra | Future |

### 5.3 Context Management

AI conversations include contextual information:
- Current trip details (destination, dates, budget)
- User preferences (dietary, accessibility, interests)
- Previous conversation history
- Saved itinerary items

### 5.4 Edge Functions

AI requests are proxied through Supabase Edge Functions for:
- API key security (keys stored server-side)
- Usage tracking and rate limiting
- Response caching
- Premium tier enforcement

### 5.5 Token Usage Limits

The app implements per-user daily token limits to control AI costs:

**Database Schema:**
```sql
-- Daily token usage tracking
CREATE TABLE public.daily_token_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    usage_date DATE NOT NULL DEFAULT CURRENT_DATE,
    tokens_used INTEGER NOT NULL DEFAULT 0,
    request_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, usage_date)
);

-- Plan type column on profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS plan_type TEXT DEFAULT 'free'
CHECK (plan_type IN ('free', 'subscription'));
```

**Key Functions:**
- `check_token_limit(user_id, free_limit, subscription_limit)` - Returns allowed status, usage stats
- `increment_token_usage(user_id, tokens)` - Increments daily usage with UPSERT

**Limits (from .env):**
- Free users: 10,000 tokens/day (~7-10 conversations)
- Subscription users: 100,000 tokens/day (~70-100 conversations)

**Implementation Files:**
- `lib/services/token_usage_service.dart` - Service with limit checking middleware
- `lib/data/repositories/token_usage_repository.dart` - CRUD operations
- `lib/services/ai_service.dart` - Integrated token checking on all AI methods
- `supabase/migrations/20251129_token_usage.sql` - Database migration

**Usage Flow:**
1. Before AI request → `_checkTokenLimit()` called
2. If limit exceeded → `AIException` with `isTokenLimitExceeded=true`
3. After successful AI response → `_recordTokenUsage(tokensUsed)` called
4. Token count from OpenAI `response.data['usage']['total_tokens']`

**UI Display:**
- Profile screen shows token usage card with progress bar
- Color-coded: green (<50%), yellow (50-80%), red (>80%)
- Shows tokens used, remaining, and daily limit

---

## 6. API Integrations

### 6.1 Google Maps SDK

```yaml
# pubspec.yaml
dependencies:
  google_maps_flutter: ^2.5.0
```

Features:
- Display maps with trip locations
- Show itinerary on map
- Navigation integration
- Custom markers for activities

### 6.2 Google Places API

Usage:
- Destination search autocomplete
- Place details (photos, reviews, hours)
- Nearby recommendations
- Geocoding and reverse geocoding

### 6.3 Future Integrations

| API | Purpose | Priority |
|-----|---------|----------|
| Amadeus | Flight search and pricing | Medium |
| Booking.com | Hotel search and pricing | Medium |
| Yelp | Restaurant recommendations | Low |
| Weather API | Trip weather forecasts | Low |

---

## 7. Monetization (Freemium)

### 7.1 Tier Comparison

| Feature | Free | Premium |
|---------|------|---------|
| Trips | 3 active | Unlimited |
| AI Chat Messages | 20/month | Unlimited |
| Trip Members | 3 per trip | 10 per trip |
| Expense Tracking | Basic | Full analytics |
| Receipt Storage | 10 MB | 1 GB |
| Export Data | No | Yes (PDF, CSV) |
| Priority Support | No | Yes |
| Ads | Yes | No |

### 7.2 Pricing (Suggested)

| Plan | Price |
|------|-------|
| Free | $0 |
| Premium Monthly | $4.99/month |
| Premium Annual | $39.99/year (~$3.33/month) |

### 7.3 Implementation

- Use **RevenueCat** for subscription management
- Store subscription status in `subscriptions` table
- Check subscription status via Edge Function before premium features
- Graceful degradation for expired subscriptions

---

## 8. UI Screens & Components

### 8.1 Authentication Flow

#### Splash Screen
```
+----------------------------------+
|                                  |
|                                  |
|          [TripBuddy Logo]        |
|                                  |
|        Your AI Travel Buddy      |
|                                  |
|         [Loading Spinner]        |
|                                  |
|                                  |
+----------------------------------+
```

Components:
- App logo (centered)
- App tagline
- Loading indicator
- Auto-navigation to Login or Home based on auth state

#### Login Screen
```
+----------------------------------+
|         [Back Arrow]             |
|                                  |
|         Welcome Back!            |
|    Sign in to continue planning  |
|                                  |
|  +----------------------------+  |
|  | Email                      |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | Password              [Eye]|  |
|  +----------------------------+  |
|                                  |
|       [Forgot Password?]         |
|                                  |
|  +----------------------------+  |
|  |        Sign In             |  |
|  +----------------------------+  |
|                                  |
|          ─── or ───              |
|                                  |
|  [Google]  [Apple]               |
|                                  |
|  Don't have an account? Sign up  |
+----------------------------------+
```

Components:
- EmailTextField (validation)
- PasswordTextField (obscure toggle)
- ForgotPasswordLink
- PrimaryButton (Sign In)
- SocialAuthButtons (Google, Apple)
- RegisterLink

#### Register Screen
```
+----------------------------------+
|         [Back Arrow]             |
|                                  |
|        Create Account            |
|   Start planning your adventures |
|                                  |
|  +----------------------------+  |
|  | Full Name                  |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | Email                      |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | Password              [Eye]|  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | Confirm Password      [Eye]|  |
|  +----------------------------+  |
|                                  |
|  [x] I agree to Terms & Privacy  |
|                                  |
|  +----------------------------+  |
|  |       Create Account       |  |
|  +----------------------------+  |
|                                  |
|  Already have an account? Login  |
+----------------------------------+
```

### 8.2 Main Navigation

Bottom Tab Bar with 5 tabs:
```
+----------------------------------+
|                                  |
|          [Screen Content]        |
|                                  |
+----------------------------------+
|  Home  | Trips | Chat | $ | Me   |
|   o    |   o   |  o   | o |  o   |
+----------------------------------+
```

### 8.3 Home/Dashboard Screen

```
+----------------------------------+
|  Good morning, John!    [Avatar] |
+----------------------------------+
|                                  |
|  +----------------------------+  |
|  |  ACTIVE TRIP               |  |
|  |  [Cover Image]             |  |
|  |  Paris Adventure           |  |
|  |  Dec 15-22 | 3 days left   |  |
|  |  Budget: $2,500            |  |
|  +----------------------------+  |
|                                  |
|  Quick Actions                   |
|  +--------+ +--------+ +------+  |
|  |New Trip| |Expense | | Chat |  |
|  +--------+ +--------+ +------+  |
|                                  |
|  Today's Itinerary               |
|  +----------------------------+  |
|  | 09:00 - Louvre Museum      |  |
|  | 13:00 - Lunch at Café...   |  |
|  | 15:00 - Eiffel Tower       |  |
|  +----------------------------+  |
|                                  |
|  Recent Expenses                 |
|  +----------------------------+  |
|  | Restaurant  | -$45.00      |  |
|  | Transport   | -$12.50      |  |
|  +----------------------------+  |
|                                  |
+----------------------------------+
```

Components:
- WelcomeHeader (user name, avatar)
- ActiveTripCard (cover, title, dates, countdown, budget)
- QuickActionsRow (3 action buttons)
- TodayItineraryList (timeline view)
- RecentExpensesList (last 3-5 expenses)

### 8.4 Trip Screens

#### Trip List
```
+----------------------------------+
|  My Trips              [+ New]   |
+----------------------------------+
|  [Filter: All v] [Sort: Date v]  |
+----------------------------------+
|                                  |
|  +----------------------------+  |
|  | [Cover Image]              |  |
|  | Paris Adventure            |  |
|  | Dec 15-22, 2025            |  |
|  | $2,500 budget | 2 members  |  |
|  | [Active]                   |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | [Cover Image]              |  |
|  | Tokyo 2026                 |  |
|  | Mar 1-10, 2026             |  |
|  | $5,000 budget | 4 members  |  |
|  | [Planning]                 |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | [Cover Image]              |  |
|  | Summer Beach Trip          |  |
|  | Jul 5-12, 2025             |  |
|  | $1,500 budget              |  |
|  | [Completed]                |  |
|  +----------------------------+  |
+----------------------------------+
```

#### Trip Detail (Tabs)
```
+----------------------------------+
|  [<]  Paris Adventure    [...]   |
+----------------------------------+
|  [                            ]  |
|  [       Cover Image          ]  |
|  [                            ]  |
+----------------------------------+
| Overview | Itinerary | Expenses | Members |
+----------------------------------+
|                                  |
|  Destination: Paris, France      |
|  Dates: Dec 15-22, 2025 (7 days) |
|  Budget: $2,500                  |
|  Spent: $847.50 (34%)            |
|                                  |
|  +----------------------------+  |
|  |     [Budget Progress Bar]  |  |
|  +----------------------------+  |
|                                  |
|  Description:                    |
|  A week exploring the City of    |
|  Light - museums, food, and...   |
|                                  |
|  +----------------------------+  |
|  |    [Plan with AI]          |  |
|  +----------------------------+  |
+----------------------------------+
```

#### Trip Itinerary
```
+----------------------------------+
|  [<]  Paris Adventure    [...]   |
+----------------------------------+
| Overview | Itinerary | Expenses | Members |
+----------------------------------+
|  Day 1 - Dec 15 (Mon)      [+]   |
|  +----------------------------+  |
|  | 09:00  Arrive at CDG       |  |
|  |        [Transport]         |  |
|  +----------------------------+  |
|  | 12:00  Check-in Hotel      |  |
|  |        [Accommodation]     |  |
|  +----------------------------+  |
|  | 15:00  Louvre Museum       |  |
|  |        [Attraction]        |  |
|  +----------------------------+  |
|  | 19:00  Dinner at Le Petit  |  |
|  |        [Food]              |  |
|  +----------------------------+  |
|                                  |
|  Day 2 - Dec 16 (Tue)      [+]   |
|  +----------------------------+  |
|  | 10:00  Eiffel Tower        |  |
|  | ...                        |  |
|  +----------------------------+  |
+----------------------------------+
```

#### Add Itinerary Item
```
+----------------------------------+
|  [X]     Add Activity     [Save] |
+----------------------------------+
|                                  |
|  Day                             |
|  +----------------------------+  |
|  | Day 1 - Dec 15          [v]|  |
|  +----------------------------+  |
|                                  |
|  Title *                         |
|  +----------------------------+  |
|  | Visit Louvre Museum        |  |
|  +----------------------------+  |
|                                  |
|  Location                        |
|  +----------------------------+  |
|  | [Search] Louvre Museum, P..|  |
|  +----------------------------+  |
|  [Map Preview]                   |
|                                  |
|  Time                            |
|  +------------+ +------------+   |
|  | Start 09:00| | End 12:00  |   |
|  +------------+ +------------+   |
|                                  |
|  Category                        |
|  [Attraction] [Food] [Transport] |
|  [Activity] [Accommodation]      |
|                                  |
|  Estimated Cost                  |
|  +----------------------------+  |
|  | $ 25.00           | USD [v]|  |
|  +----------------------------+  |
|                                  |
|  Notes                           |
|  +----------------------------+  |
|  | Book tickets online...     |  |
|  +----------------------------+  |
+----------------------------------+
```

### 8.5 AI Chat Screens

#### Chat List
```
+----------------------------------+
|  AI Chats                  [+]   |
+----------------------------------+
|                                  |
|  +----------------------------+  |
|  | Paris Adventure Chat       |  |
|  | "What restaurants do you.."|  |
|  | Today, 2:30 PM             |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | Tokyo Planning             |  |
|  | "I'll help you plan your.."|  |
|  | Yesterday                  |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | General Questions          |  |
|  | "The best time to visit..."|  |
|  | Dec 10                     |  |
|  +----------------------------+  |
+----------------------------------+
```

#### Chat Screen
```
+----------------------------------+
|  [<] Paris Chat         [...] |  |
+----------------------------------+
|                                  |
|  +----------------------------+  |
|  | AI: Hi! I'm here to help   |  |
|  | plan your Paris trip.      |  |
|  | What would you like to     |  |
|  | explore?                   |  |
|  +----------------------------+  |
|                                  |
|          +--------------------+  |
|          | What are the best |  |
|          | restaurants near  |  |
|          | the Eiffel Tower? |  |
|          +--------------------+  |
|                                  |
|  +----------------------------+  |
|  | AI: Great question! Here   |  |
|  | are my top recommendations:|  |
|  |                            |  |
|  | +------------------------+ |  |
|  | | Le Jules Verne         | |  |
|  | | Fine dining in the     | |  |
|  | | tower itself           | |  |
|  | | [Add to Itinerary]     | |  |
|  | +------------------------+ |  |
|  |                            |  |
|  | +------------------------+ |  |
|  | | Cafe Constant          | |  |
|  | | Casual French bistro   | |  |
|  | | [Add to Itinerary]     | |  |
|  | +------------------------+ |  |
|  +----------------------------+  |
|                                  |
|  +-----+ +--------------------+  |
|  | [+] | | Type a message...  |  |
|  +-----+ +--------------------+  |
+----------------------------------+
```

Components:
- ChatMessageBubble (user/assistant styles)
- RecommendationCard (actionable, add to itinerary)
- TypingIndicator (AI thinking)
- MessageInput (text field + send)
- AttachmentButton (add context)
- SuggestionChips (quick prompts)

### 8.6 Expense Screens

#### Expense List
```
+----------------------------------+
|  Expenses              [Filter]  |
+----------------------------------+
|  Trip: [Paris Adventure    v]    |
+----------------------------------+
|  Total: $847.50                  |
|  +----------------------------+  |
|  | Transport      | $125.00   |  |
|  | Food           | $312.50   |  |
|  | Activities     | $285.00   |  |
|  | Shopping       | $125.00   |  |
|  +----------------------------+  |
+----------------------------------+
|                                  |
|  Today                           |
|  +----------------------------+  |
|  | Lunch at Cafe   | -$45.00  |  |
|  | Food | You paid | Not split|  |
|  +----------------------------+  |
|  | Metro tickets   | -$12.50  |  |
|  | Transport | Split w/ John  |  |
|  +----------------------------+  |
|                                  |
|  Yesterday                       |
|  +----------------------------+  |
|  | Louvre tickets  | -$50.00  |  |
|  | Activities | Split (2)     |  |
|  +----------------------------+  |
|                                  |
|         [+ Add Expense]          |
+----------------------------------+
```

#### Add Expense
```
+----------------------------------+
|  [X]     Add Expense      [Save] |
+----------------------------------+
|                                  |
|  Amount *                        |
|  +----------------------------+  |
|  |  $ 45.00         | USD [v] |  |
|  +----------------------------+  |
|                                  |
|  Description *                   |
|  +----------------------------+  |
|  | Lunch at Cafe de Flore     |  |
|  +----------------------------+  |
|                                  |
|  Category *                      |
|  [Transport] [Accommodation]     |
|  [Food *]  [Activities]          |
|  [Shopping] [Other]              |
|                                  |
|  Date                            |
|  +----------------------------+  |
|  | Dec 16, 2025            [v]|  |
|  +----------------------------+  |
|                                  |
|  Receipt                         |
|  +----------------------------+  |
|  |  [Camera] [Gallery]        |  |
|  +----------------------------+  |
|                                  |
|  Split this expense?             |
|  ( ) No, just me                 |
|  (*) Yes, split with others      |
|                                  |
|  Split with:                     |
|  [x] John ($22.50)               |
|  [x] Sarah ($22.50)              |
|  [ ] Mike                        |
|                                  |
|  Split type: [Equal v]           |
+----------------------------------+
```

#### Expense Summary (Balances)
```
+----------------------------------+
|  [<]  Trip Balances              |
+----------------------------------+
|                                  |
|  Paris Adventure                 |
|  Total Expenses: $1,847.50       |
|                                  |
|  +----------------------------+  |
|  | You                        |  |
|  | Paid: $847.50              |  |
|  | Owe:  $615.00              |  |
|  | Balance: +$232.50          |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | John                       |  |
|  | Paid: $500.00              |  |
|  | Owe:  $615.00              |  |
|  | Balance: -$115.00          |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | Sarah                      |  |
|  | Paid: $500.00              |  |
|  | Owe:  $617.50              |  |
|  | Balance: -$117.50          |  |
|  +----------------------------+  |
|                                  |
|  Settlement Summary:             |
|  +----------------------------+  |
|  | John owes you $115.00      |  |
|  | [Request] [Mark Settled]   |  |
|  +----------------------------+  |
|  | Sarah owes you $117.50     |  |
|  | [Request] [Mark Settled]   |  |
|  +----------------------------+  |
+----------------------------------+
```

### 8.7 Profile & Settings

#### Profile Screen
```
+----------------------------------+
|  Profile                 [Edit]  |
+----------------------------------+
|                                  |
|         [Avatar Image]           |
|          John Smith              |
|      john@example.com            |
|                                  |
|  +----------------------------+  |
|  | Member since Dec 2025     |  |
|  | 5 trips planned           |  |
|  | 47 expenses tracked       |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | [Premium] Your Plan        |  |
|  | Free Plan                  |  |
|  | [Upgrade to Premium]       |  |
|  +----------------------------+  |
|                                  |
|  +----------------------------+  |
|  | Settings                 > |  |
|  +----------------------------+  |
|  | Help & Support           > |  |
|  +----------------------------+  |
|  | Privacy Policy           > |  |
|  +----------------------------+  |
|  | Terms of Service         > |  |
|  +----------------------------+  |
|                                  |
|  [Sign Out]                      |
+----------------------------------+
```

#### Edit Profile Screen
```
+----------------------------------+
|  Edit Profile            [Save]  |
+----------------------------------+
|                                  |
|         [Avatar Image]           |
|          [Camera Icon]           |
|                                  |
|  Full Name                       |
|  +----------------------------+  |
|  | John Smith                 |  |
|  +----------------------------+  |
|                                  |
|  Avatar URL                      |
|  +----------------------------+  |
|  | https://example.com/avatar |  |
|  +----------------------------+  |
|                                  |
|  Email                           |
|  +----------------------------+  |
|  | john@example.com           |  |
|  +----------------------------+  |
|  [Read Only]                     |
|                                  |
+----------------------------------+
```

#### Settings Screen
```
+----------------------------------+
|  [<]     Settings                |
+----------------------------------+
|                                  |
|  AI PREFERENCES                  |
|  +----------------------------+  |
|  | AI Provider                |  |
|  | OpenAI                   > |  |
|  +----------------------------+  |
|  | AI Model                   |  |
|  | GPT-4                    > |  |
|  +----------------------------+  |
|                                  |
|  DEFAULTS                        |
|  +----------------------------+  |
|  | Default Currency           |  |
|  | USD ($)                  > |  |
|  +----------------------------+  |
|                                  |
|  NOTIFICATIONS                   |
|  +----------------------------+  |
|  | Push Notifications    [ON] |  |
|  +----------------------------+  |
|  | Email Notifications   [ON] |  |
|  +----------------------------+  |
|  | Trip Reminders       [ON]  |  |
|  +----------------------------+  |
|                                  |
|  ACCOUNT                         |
|  +----------------------------+  |
|  | Change Password          > |  |
|  +----------------------------+  |
|  | Export My Data           > |  |
|  +----------------------------+  |
|  | Delete Account           > |  |
|  +----------------------------+  |
+----------------------------------+
```

---

## 9. MVP Roadmap

### Phase 1: Foundation - COMPLETED
**Goal:** Core infrastructure and authentication

- [x] Flutter project setup with folder structure
- [x] Supabase project configuration
- [x] Database schema creation (all tables)
- [x] Authentication flow (email, social)
- [x] Basic navigation structure
- [x] Profile management
- [x] Onboarding flow (languages, currency, destination, dates)

### Phase 2: Trip Management - COMPLETED
**Goal:** Full trip CRUD and itinerary

- [x] Trip list screen
- [x] Create/edit trip flow (fully functional)
- [x] Trip detail screen with tabs
- [x] Smart Budget Suggestions on create trip
- [x] Trip sharing with invite codes

### Phase 3: AI Integration - COMPLETED
**Goal:** Conversational trip planning

- [x] AI provider service (OpenAI - gpt-4o-mini)
- [x] Chat UI implementation
- [x] Chat session management
- [x] Context management (trip/user context to AI)
- [x] Place Recommendation cards
- [x] AI-generated chat titles
- [x] Daily Travel Tips with AI generation
- [ ] Add to itinerary from chat

### Phase 4: Expense Tracking - COMPLETED
**Goal:** Financial management for trips

- [x] Rich Expenses Dashboard with charts (pie + line)
- [x] Currency toggle (local/home currency)
- [x] Add/edit expense flow
- [x] Expense confirmation via chat
- [x] Category breakdown and stats
- [x] Category breakdown and stats
- [ ] Expense splitting logic
- [ ] Balance calculations
- [ ] Settlement tracking

### Phase 5: Journal - COMPLETED
**Goal:** AI-powered trip journaling

- [x] Journal entries database schema
- [x] Journal list and detail screens
- [x] AI-generated journal entries
- [x] Mood tracking
- [x] Highlights and locations extraction
- [x] Automatic daily journal generation (no manual trigger)
- [x] End-of-trip notification ("Your Journal is Ready!")
- [x] Journal export (Text/Markdown via share sheet)

### Phase 6: Polish & Launch - IN PROGRESS
**Goal:** Production readiness

- [x] Multi-language support (12 languages)
- [x] RTL support (Hebrew, Arabic)
- [x] Currency conversion fixes
- [ ] Settings screen with preferences
- [ ] Premium subscription flow
- [ ] RevenueCat integration
- [x] Onboarding experience
- [ ] Error handling and edge cases
- [ ] Performance optimization
- [ ] App store submission

---

## 10. Feature Implementation Plan

### User Preferences
- **Priority:** Expenses Dashboard first
- **Journal AI Level:** Full AI Generation
- **Charts:** Yes - Full Charts (pie + line)

---

### PHASE 1: Rich Expenses Dashboard - COMPLETED

#### 1.1 Data Layer Enhancement

**Created `lib/data/models/expense_stats.dart`:**
```dart
class ExpenseStats {
  final double totalSpent;
  final double dailyAverage;
  final double estimatedTripTotal;
  final String displayCurrency;
  final int totalExpenseCount;
  final int tripDays;
  final int elapsedDays;
  final int remainingDays;
}

class DailySpending {
  final DateTime date;
  final double amount;
}

class CategoryTotal {
  final String category;
  final double amount;
  final double percentage;
  final int count;
}
```

**Enhanced `lib/data/repositories/expenses_repository.dart`:**
- Added `getDailySpendingData(tripId)` - groups expenses by date for chart
- Added `getExpensesByDateRange(tripId, startDate, endDate)`

**Enhanced `lib/presentation/providers/expenses_provider.dart`:**
- `showInHomeCurrencyProvider` - StateProvider<bool>
- `selectedExpensesTripIdProvider` - Selected trip context
- `ExpensesDashboardData` - Combined dashboard data class
- `expensesDashboardProvider` - Main dashboard data provider
- `expensesByCategoryProvider` - Category filter provider
- `expensesDashboardRefreshProvider` - Refresh function

#### 1.2 Widget Components

**Created new widgets:**
| File | Purpose |
|------|---------|
| `lib/presentation/widgets/charts/expense_pie_chart.dart` | Category breakdown pie chart |
| `lib/presentation/widgets/charts/spending_line_chart.dart` | Spending over time line chart |
| `lib/presentation/widgets/expenses/summary_stat_card.dart` | Animated stat display |
| `lib/presentation/widgets/expenses/category_card.dart` | Tappable category with total |
| `lib/presentation/widgets/expenses/expense_list_tile.dart` | Expense item display |
| `lib/presentation/widgets/expenses/category_detail_sheet.dart` | Bottom sheet drill-down |

#### 1.3 Expenses Screen Features
- Currency toggle button (Local/Home) in AppBar
- Summary stats section with 3 cards (Total, Daily Average, Estimated Total)
- Trip info banner showing current trip
- Category pie chart with interactive tap
- 2x3 category card grid
- Spending over time line chart
- Pull-to-refresh
- Loading and error states
- Empty state with CTA

---

### PHASE 2: Smart Expense Tracking via Chat - COMPLETED

#### 2.1 AI Expense Parsing - DONE
- Added expense extraction to `lib/services/ai_service.dart`
- Parses: amount, currency, category, description, date
- Returns structured JSON when expense detected

#### 2.2 Chat Expense Confirmation Flow - DONE
- Created `lib/presentation/widgets/chat/expense_confirmation_card.dart`
- Inline confirmation card with Edit/Save/Cancel
- Integrates with ExpensesRepository

#### 2.3 Files Created
- `lib/presentation/widgets/chat/expense_confirmation_card.dart` - Expense confirmation widget

---

### PHASE 3: Automatic Trip Journal (Full AI Generation) - COMPLETED

#### 3.1 Database Schema - DONE

**Created migration `supabase/migrations/20251125_journal_schema.sql`:**
```sql
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  entry_date DATE NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  ai_generated BOOLEAN DEFAULT true,
  source_data JSONB DEFAULT '{}', -- chat message IDs, expense IDs used to generate
  photos TEXT[] DEFAULT '{}', -- array of photo URLs
  mood TEXT CHECK (mood IN ('excited', 'relaxed', 'tired', 'adventurous', 'inspired', 'grateful', 'reflective')),
  locations TEXT[] DEFAULT '{}', -- places mentioned/visited
  weather TEXT,
  highlights TEXT[] DEFAULT '{}', -- key highlights
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(trip_id, entry_date, user_id)
);
```

#### 3.2 Data Layer - DONE

**Created:**
- `lib/data/models/journal_model.dart` - JournalEntry model with JournalMood enum
- `lib/data/repositories/journal_repository.dart` - Full CRUD operations including upsert
- `lib/presentation/providers/journal_provider.dart` - Complete state management with:
  - `tripJournalEntriesProvider` - Fetch entries for a trip
  - `journalOperationProvider` - StateNotifier for create/update/delete
  - `shouldShowJournalPromptProvider` - Check if prompt should be shown
  - `journalRefreshProvider` - Refresh function
  - **NEW:** `journalAutoGenResultProvider` - Auto-generation on app open
  - **NEW:** `shouldShowJournalReadyProvider` - Show notification when trip ends

#### 3.3 AI Journal Generation - DONE

**Enhanced `lib/services/ai_service.dart`:**
- Added `generateJournalEntry(chatMessages, date, tripDestination, expenses)` method
- Added `journalGenerationPrompt` with structured JSON output
- Added `_parseJournalResponse()` to extract title, content, mood, highlights, locations
- Returns `GeneratedJournalContent` object

#### 3.4 Automatic Journal Generation - DONE (v1.8.0)

**Created `lib/services/journal_auto_generator.dart`:**
- `JournalAutoGenerator` service for automatic entry generation
- `generateForActiveTrip()` - Generates entries for active trip on app open
- `generateMissingEntries(trip)` - Scans trip date range, finds days without entries
- Only generates for days with activity (chat messages or expenses)
- 500ms delay between API calls for rate limiting
- Returns `AutoGenResult` with counts and trip-end notification flag

**Created `lib/presentation/widgets/home/journal_ready_card.dart`:**
- Celebratory notification card shown when trip ends and journal is ready
- Gradient background with auto_stories icon
- Shows count of generated entries and trip name
- "View Journal" button navigates to trip's journal
- Dismissible with X button

**Updated Home Screen:**
- Shows JournalReadyCard at top when `shouldShowJournalReady` is true
- Auto-generates journal entries silently on app open
- Notification only appears when trip has ended (within 7 days)

#### 3.5 Journal UI - DONE

**Created `lib/presentation/screens/journal/journal_screen.dart`:**
- List view of journal entries (read-only, no manual creation)
- JournalEntryCard with day number, date, mood emoji, AI badge, highlights, locations
- Empty state explaining AI auto-generates entries daily
- Export button in AppBar (Text/Markdown formats)
- Pull-to-refresh

**Created `lib/presentation/screens/journal/journal_entry_screen.dart`:**
- View mode for reading AI-generated entries
- Edit mode for modifying existing entries (after AI generates)
- Removed manual "Generate with AI" button (fully automatic now)
- Mood selector with FilterChips
- Delete confirmation dialog

**Added Journal section to Trip Detail Screen:**
- Journal card with entry count and AI generation stats
- Latest entry preview
- Navigation to full Journal screen

#### 3.6 Journal Export - DONE (v1.8.0)

**Export functionality in `journal_screen.dart`:**
- Share button in AppBar when entries exist
- Format selection dialog (Text .txt or Markdown .md)
- Generates formatted document with:
  - Trip title and date range header
  - Each day's entry with day number, date, title, mood
  - Content, highlights, and locations visited
  - "Generated by Travel AI Companion" footer
- Uses share_plus package for native share sheet

#### 3.7 Files Created/Updated
- `supabase/migrations/20251125_journal_schema.sql`
- `lib/data/models/journal_model.dart`
- `lib/data/repositories/journal_repository.dart`
- `lib/presentation/providers/journal_provider.dart` (with auto-gen providers)
- `lib/presentation/screens/journal/journal_screen.dart` (read-only + export)
- `lib/presentation/screens/journal/journal_entry_screen.dart` (no manual generation)
- `lib/services/journal_auto_generator.dart` (NEW - auto generation service)
- `lib/presentation/widgets/home/journal_ready_card.dart` (NEW - notification card)
- Updated `lib/services/ai_service.dart` with journal generation
- Updated `lib/presentation/screens/trips/trip_detail_screen.dart` with Journal section
- Updated `lib/presentation/screens/home/home_screen.dart` with journal notification
- Added `share_plus` and `path_provider` to pubspec.yaml

---

### PHASE 4: Personalized Travel Recommendations - PENDING

#### 4.1 Context-Aware AI

**Enhance `lib/services/ai_service.dart`:**
- Accept user context in sendMessage:
  - Languages spoken
  - Current destination
  - Trip dates
  - Budget
  - Past preferences (from chat history)

**Enhanced system prompt:**
```
You are TripBuddy. The user speaks: {languages}. They are in {destination}
from {startDate} to {endDate} with a budget of {budget}.
Personalize recommendations based on their preferences and location.
```

#### 4.2 Location-Based Tips

**When user starts a new trip or changes location:**
- AI proactively sends welcome message with:
  - Local customs and etiquette
  - Currency and tipping practices
  - Safety tips
  - Must-try local experiences

---

### PHASE 5: Polish & Remaining Features - PENDING

#### 5.1 Complete Add Expense Screen
- Full form with all fields
- Category picker
- Date picker
- Receipt photo upload
- Save to database

#### 5.2 Trips List & Detail
- Show all trips (not just active)
- Complete Trip Detail tabs (Overview, Itinerary, Expenses, Members)
- Create Trip functionality

#### 5.3 Profile & Settings
- Real stats from database
- Settings screen with preferences
- [x] Edit profile functionality
- Edit Profile screen design

---

## Critical Files Reference

| File | Status | Notes |
|------|--------|-------|
| **Screens** | | |
| `lib/presentation/screens/expenses/expenses_screen.dart` | Complete | Full dashboard with charts |
| `lib/presentation/screens/expenses/add_expense_screen.dart` | Complete | Add/edit expense form |
| `lib/presentation/screens/chat/chat_screen.dart` | Complete | AI chat with expense confirmation |
| `lib/presentation/screens/journal/journal_screen.dart` | Complete | Journal list screen |
| `lib/presentation/screens/journal/journal_entry_screen.dart` | Complete | View/edit journal entries |
| `lib/presentation/screens/trips/trip_detail_screen.dart` | Complete | Trip detail with all tabs |
| `lib/presentation/screens/trips/create_trip_screen.dart` | Complete | Create trip with smart budget |
| `lib/presentation/screens/trips/trips_screen.dart` | Complete | Trip list |
| `lib/presentation/screens/home/home_screen.dart` | Complete | Dashboard with daily tips |
| `lib/presentation/screens/profile/profile_screen.dart` | Complete | User profile |
| **Providers** | | |
| `lib/presentation/providers/expenses_provider.dart` | Complete | Dashboard providers |
| `lib/presentation/providers/journal_provider.dart` | Complete | Journal state management |
| `lib/presentation/providers/chat_provider.dart` | Complete | Chat state with expense handling |
| `lib/presentation/providers/trips_provider.dart` | Complete | Trip state management |
| `lib/presentation/providers/currency_provider.dart` | Complete | Currency conversion |
| `lib/presentation/providers/day_tip_provider.dart` | Complete | Daily tips state |
| **Services** | | |
| `lib/services/ai_service.dart` | Complete | AI generation (chat, journal, tips, budget) + token limits |
| `lib/services/journal_auto_generator.dart` | Complete | Automatic journal generation on app open |
| `lib/services/token_usage_service.dart` | Complete | Token usage limit checking middleware |
| `lib/services/currency_service.dart` | Complete | Exchange rates |
| `lib/services/budget_estimation_service.dart` | Complete | Smart budget suggestions |
| `lib/services/auth_service.dart` | Complete | Authentication |
| **Repositories** | | |
| `lib/data/repositories/expenses_repository.dart` | Complete | Full CRUD + stats |
| `lib/data/repositories/journal_repository.dart` | Complete | Full CRUD for journals |
| `lib/data/repositories/trips_repository.dart` | Complete | Full CRUD for trips |
| `lib/data/repositories/chat_repository.dart` | Complete | Chat session management |
| `lib/data/repositories/token_usage_repository.dart` | Complete | Token usage CRUD + limit checking |
| **Models** | | |
| `lib/data/models/expense_model.dart` | Complete | Expense data model |
| `lib/data/models/expense_stats.dart` | Complete | Stats for dashboard |
| `lib/data/models/journal_model.dart` | Complete | Journal with mood enum |
| `lib/data/models/trip_model.dart` | Complete | Trip data model |
| `lib/data/models/day_tip_model.dart` | Complete | Daily tip model |
| `lib/data/models/travel_context.dart` | Complete | AI context model |
| **Widgets** | | |
| `lib/presentation/widgets/chat/expense_confirmation_card.dart` | Complete | Expense save from chat |
| `lib/presentation/widgets/chat/place_recommendation_card.dart` | Complete | AI place recommendations |
| `lib/presentation/widgets/chat/journal_reminder_card.dart` | Complete | Journal prompt in chat |
| `lib/presentation/widgets/home/day_tip_card.dart` | Complete | Daily travel tip display |
| `lib/presentation/widgets/home/journal_ready_card.dart` | Complete | End-of-trip journal notification |
| `lib/presentation/widgets/trip/smart_budget_suggestions_card.dart` | Complete | Budget suggestions |
| `lib/presentation/widgets/charts/expense_pie_chart.dart` | Complete | Category breakdown |
| `lib/presentation/widgets/charts/spending_line_chart.dart` | Complete | Spending over time |
| **Config** | | |
| `lib/config/theme.dart` | Reference | Colors, categoryColors |
| `lib/config/routes.dart` | Complete | App routing |
| `lib/config/constants.dart` | Complete | App constants |
| **Localization (i18n)** | | |
| `lib/l10n/app_en.arb` | Complete | English (base) - ~220 keys |
| `lib/l10n/app_es.arb` | Complete | Spanish |
| `lib/l10n/app_fr.arb` | Complete | French |
| `lib/l10n/app_de.arb` | Complete | German |
| `lib/l10n/app_it.arb` | Complete | Italian |
| `lib/l10n/app_pt.arb` | Complete | Portuguese |
| `lib/l10n/app_ja.arb` | Complete | Japanese |
| `lib/l10n/app_zh.arb` | Complete | Chinese (Simplified) |
| `lib/l10n/app_ko.arb` | Complete | Korean |
| `lib/l10n/app_ru.arb` | Complete | Russian |
| `lib/l10n/app_ar.arb` | Complete | Arabic (RTL) |
| `lib/l10n/app_he.arb` | Complete | Hebrew (RTL) |

---

## Packages Available
- fl_chart: ^0.68.0 (charts) - USING
- shimmer: ^3.0.0 (loading states) - AVAILABLE
- intl: ^0.20.2 (formatting) - USING

## Packages to Add (Phase 3)
- pdf: ^3.10.0 (journal export)
- share_plus: ^7.2.0 (sharing)

---

## 11. Folder Structure

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── constants.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── error/
│   ├── network/
│   └── utils/
├── data/
│   ├── models/
│   │   ├── user.dart
│   │   ├── trip.dart
│   │   ├── itinerary_item.dart
│   │   ├── expense.dart
│   │   └── chat_message.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── trip_repository.dart
│   │   ├── expense_repository.dart
│   │   └── chat_repository.dart
│   └── datasources/
│       ├── supabase_datasource.dart
│       └── local_datasource.dart
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── blocs/ (or providers/)
│   │   ├── auth/
│   │   ├── trip/
│   │   ├── expense/
│   │   └── chat/
│   ├── screens/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── trips/
│   │   ├── chat/
│   │   ├── expenses/
│   │   └── profile/
│   └── widgets/
│       ├── common/
│       ├── trip/
│       ├── expense/
│       └── chat/
└── services/
    ├── ai/
    │   ├── ai_provider.dart
    │   ├── openai_provider.dart
    │   ├── openrouter_provider.dart
    │   └── gemini_provider.dart
    ├── maps/
    │   └── places_service.dart
    └── storage/
        └── storage_service.dart
```

---

## 12. Environment Variables

```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key

# AI Providers (stored in Supabase Edge Functions secrets)
OPENAI_API_KEY=sk-...
OPENROUTER_API_KEY=sk-or-...
GOOGLE_AI_API_KEY=...

# Google Maps
GOOGLE_MAPS_API_KEY=AIza...

# RevenueCat
REVENUECAT_API_KEY=...
```

---

## Changelog

### v1.10.0 (November 29, 2025)
- **Shared Trips Feature - COMPLETE:**
  - Users can share trips with friends via 8-character invite codes
  - "Invite Friends" button on trip detail screen (owner only)
  - Share sheet with copy code and native share functionality
  - "Join Trip" button in trips list header
  - Join trip screen with code input validation
  - Trip members card showing all participants with avatars
  - "Shared" badge on trips list for shared trips
  - Owner badge (star icon) on trip member avatars
- **Database Schema:**
  - Added `invite_code` column to trips table
  - Created `get_or_create_invite_code()` PostgreSQL function
  - Created `join_trip_by_code()` PostgreSQL function with validation
  - Created `get_trip_members()` PostgreSQL function
  - RLS policies for trip members access
- **Files Created:**
  - `lib/data/models/trip_member_model.dart`
  - `lib/services/trip_sharing_service.dart`
  - `lib/presentation/providers/trip_sharing_provider.dart`
  - `lib/presentation/widgets/trips/trip_members_card.dart`
  - `lib/presentation/widgets/trips/share_trip_sheet.dart`
  - `lib/presentation/screens/trips/join_trip_screen.dart`
  - `supabase/migrations/20251129_shared_trips.sql`
- **Files Updated:**
  - `lib/data/models/trip_model.dart` (added `isOwner`, `isShared` getters)
  - `lib/data/repositories/trips_repository.dart` (fetch current user ID)
  - `lib/presentation/screens/trips/trip_detail_screen.dart` (members card, share action)
  - `lib/presentation/screens/trips/trips_screen.dart` (shared badge, join button)
  - `lib/config/routes.dart` (joinTrip route)
  - `lib/l10n/app_en.arb`, `lib/l10n/app_he.arb` (trip sharing localization keys)

### v1.9.0 (November 29, 2025)
- **Referral System - COMPLETE:**
  - Users get unique 8-character referral code in Profile → "Invite Friends"
  - New users can enter referral code during registration
  - Both referrer and referred user get 50 credits (5000 tokens)
  - Share functionality with native share sheet
  - Tracks referral stats: friends invited, credits earned
- **Database Schema:**
  - Added `referral_code`, `referred_by`, `referral_credits_earned` to profiles
  - Created `referrals` table for tracking referral history
  - PostgreSQL functions: `generate_referral_code()`, `ensure_referral_code()`, `process_referral()`, `get_referral_stats()`
- **Files Created:**
  - `lib/services/referral_service.dart`
  - `supabase/migrations/20251129100003_referral_system.sql`
  - `supabase/referral_system_standalone.sql`
- **Files Updated:**
  - `lib/presentation/screens/profile/profile_screen.dart` (Invite Friends card)
  - `lib/presentation/screens/auth/register_screen.dart` (referral code input)
  - `lib/l10n/app_en.arb` (referral localization keys)

### v1.8.0 (November 29, 2025)
- **Automatic Trip Journal - COMPLETE:**
  - Journal entries now auto-generated daily on app open (no manual trigger)
  - Created `JournalAutoGenerator` service for client-side auto-generation
  - Scans trip date range, finds days with activity (chats/expenses), generates entries
  - 500ms delay between API calls for rate limiting
  - End-of-trip notification with `JournalReadyCard` widget
  - Notification shows when trip ended within last 7 days
- **Journal Export - COMPLETE:**
  - Added share button in journal screen AppBar
  - Export to Text (.txt) or Markdown (.md) format
  - Formatted document with trip title, dates, day entries, moods, highlights
  - Uses share_plus package for native share sheet
- **Journal UI Changes:**
  - Removed manual "Generate with AI" button
  - Removed "New Entry" FAB - entries are auto-generated only
  - Updated empty state to explain AI generates entries daily
  - Users can still view and edit AI-generated entries
- **Files Created:**
  - `lib/services/journal_auto_generator.dart`
  - `lib/presentation/widgets/home/journal_ready_card.dart`
- **Files Updated:**
  - `lib/presentation/providers/journal_provider.dart` (auto-gen providers)
  - `lib/presentation/screens/journal/journal_screen.dart` (export + read-only)
  - `lib/presentation/screens/journal/journal_entry_screen.dart` (no manual gen)
  - `lib/presentation/screens/home/home_screen.dart` (journal notification)
  - `pubspec.yaml` (share_plus, path_provider)

### v1.7.0 (November 29, 2025)
- **Sprint 3 & 4 Completions:**
  - Full dark theme implementation in `lib/config/theme.dart`
  - Settings screen fully functional (dark mode, date format, distance units, privacy)
  - New Chat FAB button added to chat list screen
  - Trip flag emoji shown as chat session icon (with destination subtitle)
  - Enhanced chat title generation with trip context and language support
  - Fixed token usage service initialization error (lazy Supabase init)
- **Files Updated:**
  - `lib/config/theme.dart` (complete dark theme)
  - `lib/data/models/chat_models.dart` (added tripFlagEmoji, tripDestination)
  - `lib/data/repositories/chat_repository.dart` (JOIN with trips for flag)
  - `lib/data/repositories/token_usage_repository.dart` (lazy init fix)
  - `lib/presentation/screens/chat/chat_list_screen.dart` (FAB + flag icons)
  - `lib/presentation/providers/chat_provider.dart` (trip context in title gen)
  - `lib/services/ai_service.dart` (enhanced generateChatTitle)

### v1.6.0 (November 29, 2025)
- **Token Usage Limits - COMPLETE:**
  - Per-user daily token limits to control AI costs
  - Database: `daily_token_usage` table with automatic date-based reset
  - Added `plan_type` column to profiles (free/subscription)
  - PostgreSQL functions: `check_token_limit()`, `increment_token_usage()`
  - Token limit middleware integrated into all AI methods
  - Profile screen shows token usage card with progress bar
  - Color-coded usage status (green/yellow/red)
  - Environment variables: `FREE_DAILY_TOKENS=10000`, `SUBSCRIPTION_DAILY_TOKENS=100000`
- **Files Created:**
  - `supabase/migrations/20251129_token_usage.sql`
  - `lib/services/token_usage_service.dart`
  - `lib/data/repositories/token_usage_repository.dart`
- **Files Updated:**
  - `lib/services/ai_service.dart` (token limit checking on all methods)
  - `lib/presentation/screens/profile/profile_screen.dart` (usage display)
  - `lib/l10n/app_en.arb` (new localization keys)
  - `.env` (token limit variables)

### v1.5.0 (November 29, 2025)
- **Multi-Language Support (i18n) - COMPLETE:**
  - Full localization for 12 languages (en, es, fr, de, he, ja, zh, ko, it, pt, ru, ar)
  - RTL support for Hebrew and Arabic
  - All screens localized: Home, Trips, Expenses, Chat, Profile, Onboarding
  - ~220 localization keys per language
  - AI chatbot responds in user's selected language
- **Currency Conversion Fix:**
  - Fixed `convertSync` in CurrencyService - amounts now properly convert when switching currency modes
  - Exchange rates fetched dynamically when switching between Home/USD/Local currencies
  - Proper cross-currency conversion through base currency
- **Files Updated:**
  - `lib/l10n/app_*.arb` (all 12 language files)
  - `lib/services/currency_service.dart` (conversion fix)
  - `lib/presentation/screens/expenses/expenses_screen.dart` (localization + currency fix)
  - `lib/presentation/screens/expenses/add_expense_screen.dart` (localization)
  - `lib/presentation/screens/profile/profile_screen.dart` (localization)

### v1.4.0 (November 26, 2025)
- **New Features:**
  - Smart Budget Suggestions on Create Trip screen
    - Created BudgetEstimationService with 60+ country data
    - SmartBudgetSuggestionsCard with active/inactive states
    - Automatic currency conversion for 35+ currencies
  - Daily Travel Tips on Home screen
    - Created DayTipModel and DayTipProvider
    - DayTipCard widget with category-based styling
    - AI-generated tips via AIService
  - Country flags and centralized currency handling
  - AI-generated chat titles
- **Architecture Update:**
  - Updated MVP Roadmap to reflect actual completion status
  - Reorganized phases (added Phase 5: Journal, Phase 6: Polish)
  - Updated Critical Files Reference table
  - Cleaned up outdated PENDING sections

### v1.3.0 (November 25, 2025)
- **Phase 3 Complete**: Automatic Trip Journal with AI Generation
  - Created journal_entries database migration with mood, locations, highlights
  - Implemented JournalModel with JournalMood enum
  - Created JournalRepository with full CRUD + upsert
  - Built journal_provider with state management
  - Added AI journal generation to AIService
  - Created JournalScreen with entry cards
  - Created JournalEntryScreen with view/edit modes
  - Added Journal section to Trip Detail Screen

### v1.2.0 (November 25, 2025)
- Bug fixes: expenses not saving, settings currency sync
- Fixed Riverpod provider initialization error
- Added documentation maintenance instructions to claude.md

### v1.1.0 (November 2025)
- Phase 1 Complete: Rich Expenses Dashboard
- Phase 2 Complete: Smart Expense Tracking via Chat
- Trip Detail Screen enhancements

### v1.0.0 (Initial)
- Initial architecture specification
- Database schema design
- UI wireframes
- MVP roadmap

---

## Upcoming Features (Implementation Plan)

### Sprint 1: Dashboard Improvements
- [ ] Limit Recent Chats to 4 items with "View All" link
- [ ] Limit Recent Expenses to 4 items with "View All" link

### Sprint 2: Multi-Language Support (i18n) - COMPLETED
- [x] Add flutter_localizations and intl packages
- [x] Create ARB files for 12 languages:
  - English (en), Spanish (es), French (fr), German (de)
  - Hebrew (he), Japanese (ja), Chinese (zh), Korean (ko)
  - Italian (it), Portuguese (pt), Russian (ru), Arabic (ar)
- [x] Support RTL for Hebrew and Arabic
- [x] Create LocaleProvider for language management
- [x] Store language preference in user_settings table
- [x] Update AI chatbot to respond in user's selected language
- [x] Translate all screens using AppLocalizations:
  - Home screen (greetings, quick actions, recent chats/expenses)
  - Trips screens (list, detail, create)
  - Expenses screens (dashboard, add expense)
  - Chat screens (welcome, prompts, messages)
  - Profile screen (stats, settings, sign out)
  - Onboarding flow (language selection)
  - Daily Tips feature

### Sprint 3: Expanded Settings & Profile - FULLY COMPLETED
- [x] **General Settings:**
  - App Language (with flag icons)
  - Default Currency
  - Date Format (DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD)
  - Distance Units (Kilometers / Miles)
  - Dark Mode Toggle (full dark theme implementation)
- [x] **Notifications:**
  - Push Notifications toggle
  - Email Notifications toggle
  - Trip Reminders toggle
- [x] **Privacy:**
  - Share usage analytics toggle
  - Location tracking toggle
- [x] **Account:**
  - Change Password (with dialog and Supabase update)
  - Export My Data (email notification)
  - Reset Account (full data wipe with RPC)
  - Delete Account (with confirmation)
- [x] **About:**
  - App Version (dynamic from package_info_plus)
  - Terms of Service, Privacy Policy links
  - Rate App dialog
- [x] Profile Screen Expansion:
  - Quick settings shortcuts (language selector card)
  - Member since date (shown in profile header)
  - [x] Invite Friends / Referral System (COMPLETED v1.9.0)

### Sprint 4: Feature Enhancements & Bug Fixes - COMPLETED
- [ ] **Multi-Language Fixes:**
  - Ensure Daily Tips use the selected locale (currently English only).
- [x] **Daily Tips Redesign:**
  - Change to show 3 random short tips in different categories (instead of one long tip).
  - Update `DayTipProvider` and UI.
- [x] **AI Chat Improvements:**
  - Add prominent "New Chat" FAB button (FloatingActionButton.extended).
  - Use Trip Flag as icon for chat sessions (with trip destination subtitle).
  - Improve chat title generation logic (now includes trip context, language support).
- [x] **Automated Trip Journal:**
  - Fully automate journal generation based on daily activities/chat.
  - Removed manual "Generate with AI" button - fully automatic now.
  - Created `JournalAutoGenerator` service for client-side auto-generation.
  - Added `JournalReadyCard` notification when trip ends.
  - Added export functionality (Text/Markdown via share sheet).
- [x] **Bug Fixes:**
  - Fixed "GlobalKey used multiple times" error in Expenses Summary.

### Sprint 5: Shared Trips (Couples/Groups) - COMPLETED
- [x] Add "Share Trip" button on trip detail screen
- [x] Generate shareable invite code (8-character)
- [x] Share sheet with copy code and native share
- [x] Members list view with owner badge (star icon)
- [x] Add invite_code column to trips table
- [x] Join trip screen (enter code)
- [x] Created TripSharingService and trip_sharing_provider
- [x] Update trips list to show "Shared" badge for shared trips
- [x] Join Trip button in trips list header

### Sprint 6: Polish & Future
- [ ] PDF export for journals
- [ ] Premium subscription flow (RevenueCat)
- [ ] Error handling improvements
- [ ] Performance optimization
- [ ] Expense splitting and settlements
- [ ] App store submission (iOS & Android)

---

## Database Changes Required

### User Settings Table Updates
```sql
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS app_language TEXT DEFAULT 'en';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS date_format TEXT DEFAULT 'DD/MM/YYYY';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS distance_unit TEXT DEFAULT 'km';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS dark_mode BOOLEAN DEFAULT false;
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS share_analytics BOOLEAN DEFAULT true;
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS location_tracking BOOLEAN DEFAULT true;
```

### Trip Sharing Tables
```sql
-- Add share code to trips
ALTER TABLE trips ADD COLUMN IF NOT EXISTS share_code TEXT UNIQUE;

-- Trip invitations table
CREATE TABLE IF NOT EXISTS trip_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    invited_by UUID REFERENCES profiles(id),
    role TEXT DEFAULT 'editor' CHECK (role IN ('editor', 'viewer')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'expired')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days',
    UNIQUE(trip_id, email)
);

-- RLS for invitations
ALTER TABLE trip_invitations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view invitations for their email" ON trip_invitations
    FOR SELECT USING (email = auth.jwt()->>'email');

CREATE POLICY "Trip owners can manage invitations" ON trip_invitations
    FOR ALL USING (
        EXISTS (SELECT 1 FROM trips WHERE id = trip_id AND owner_id = auth.uid())
    );
```

---

## Deferred Features

- Receipt photo capture (moved to Sprint 5)
- AI Model selection in settings (dev controlled for now)
