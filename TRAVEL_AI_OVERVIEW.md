# TravelAI (TripBuddy) Project Overview

## 1. Project Identity
**Project Name:** TripBuddy (Directory: `travel-ai`)
**Purpose:** An AI-powered travel assistant mobile application designed to help users plan trips, manage itineraries, and track expenses.
**Core Value:** Combines conversational AI for planning with practical tools for itinerary management and expense splitting.

## 2. Technology Stack

### Frontend (Mobile App)
- **Framework:** Flutter (Cross-platform for iOS & Android)
- **Language:** Dart
- **State Management:** `flutter_riverpod` (with `riverpod_annotation` & `riverpod_generator`)
- **Navigation:** `go_router`
- **Networking:** `dio`
- **Local Storage:** `flutter_secure_storage` (for credentials), `shared_preferences`
- **UI Components:** `flutter_svg`, `cached_network_image`, `shimmer`, `flutter_form_builder`

### Backend (BaaS)
- **Platform:** Supabase
- **Database:** PostgreSQL
- **Authentication:** Supabase Auth (Email/Password, Social Login via Google/Apple)
- **Storage:** Supabase Storage (Receipts, Images)
- **Edge Functions:** Deno (for AI proxying and business logic)

### AI & Intelligence
- **Primary Provider:** OpenAI (GPT-4)
- **Future Providers:** OpenRouter, Google Gemini
- **Integration:** Chat interface for trip planning and recommendations

### External APIs
- **Maps:** Google Maps SDK (planned)
- **Places:** Google Places API (planned)

## 3. Core Features

### 🤖 AI Trip Planner
- Conversational interface to plan trips.
- Context-aware recommendations for destinations, hotels, and activities.
- Auto-generation of itineraries from chat.

### 📅 Itinerary Management
- Day-by-day activity planning.
- Map view of daily activities.
- Collaborative editing (Owner, Editor, Viewer roles).

### 💰 Expense Tracking & Splitting
- Log expenses by category (Transport, Food, etc.).
- Split costs among trip members.
- Track "Who owes who" and settle debts.
- Receipt scanning and storage.

### 👥 Collaboration
- Shared trips with multiple members.
- Real-time updates (via Supabase Realtime).

## 4. Architecture & Data Model

### Database Schema Highlights
- **Profiles:** User data linked to Auth.
- **Trips:** Core entity containing destination, dates, and budget.
- **TripMembers:** Junction table for user-trip relationships with roles.
- **ItineraryItems:** Activities linked to specific days of a trip.
- **Expenses & Splits:** Financial tracking with support for group splitting.
- **ChatSessions & Messages:** History of AI interactions per trip.

### Security
- **RLS (Row Level Security):** Strict policies ensuring users can only access data they own or are shared with.

## 5. Development Workflow
- **Branching Strategy:** Feature branches (`feature/`, `fix/`) merged into `main`. Direct commits to `main` are prohibited.
- **Code Quality:** `flutter_lints` enabled.
- **Testing:** Unit, Widget, and Integration tests required.
- **Documentation:** `architecture.md` serves as the source of truth for specs.

## 6. Current Status
- **Phase:** MVP Development
- **Version:** 1.0.0+1
- **Next Steps:** Implementing core features defined in `architecture.md`.
