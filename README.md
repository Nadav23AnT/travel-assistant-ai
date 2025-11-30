<p align="center">
  <img src="assets/icons/app_icon.png" alt="Waylo Logo" width="120" height="120">
</p>

<h1 align="center">Waylo</h1>

<p align="center">
  <strong>Your AI-Powered Travel Companion</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase">
  <img src="https://img.shields.io/badge/OpenAI-GPT--4o-412991?logo=openai" alt="OpenAI">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
</p>

---

## Overview

**Waylo** is a cross-platform travel companion app that combines AI-powered assistance with practical travel tools. Plan trips, track expenses, journal your experiences, and get personalized recommendations - all in one beautiful, intuitive app.

Built with Flutter for iOS, Android, Web, macOS, Windows, and Linux.

---

## Features

### AI Travel Assistant
- Smart conversational AI powered by OpenAI GPT-4o
- Context-aware travel recommendations
- Multi-provider support (OpenAI, OpenRouter, Google Gemini)
- Per-feature AI model configuration

### Trip Management
- Create and organize multiple trips
- Set destinations with country flags
- Track trip dates and budgets
- Share trips with friends and family via invite codes

### Expense Tracking
- Log expenses by category (Transport, Accommodation, Food, Activities, Shopping, Other)
- Multi-currency support with automatic conversion
- Visual spending breakdowns
- Edit and delete expense history

### Travel Journal
- Document daily experiences
- AI-generated summaries
- Export to beautifully formatted PDF
- Photo attachments support

### Smart Features
- Daily personalized travel tips
- Offline-first architecture with local caching
- Real-time sync across devices
- Dark and light theme support

### Multi-Language Support
12 languages supported:
- English, Spanish, French, German, Italian, Portuguese
- Russian, Japanese, Korean, Chinese
- Arabic, Hebrew (RTL support)

---

## Screenshots

<p align="center">
  <i>Screenshots coming soon</i>
</p>

<!--
<p align="center">
  <img src="screenshots/home.png" width="200" alt="Home Screen">
  <img src="screenshots/chat.png" width="200" alt="AI Chat">
  <img src="screenshots/expenses.png" width="200" alt="Expenses">
  <img src="screenshots/journal.png" width="200" alt="Journal">
</p>
-->

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10.0 or higher)
- [Supabase Account](https://supabase.com)
- [OpenAI API Key](https://platform.openai.com/api-keys)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nadav23AnT/travel-assistant-ai.git
   cd travel-assistant-ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Copy the example environment file and add your keys:
   ```bash
   cp .env.example .env
   ```

   Edit `.env` with your credentials:
   ```env
   # Supabase
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key

   # OpenAI
   OPENAI_API_KEY=your_openai_api_key

   # AI Feature Configuration (optional)
   AI_CHAT_PROVIDER=openai
   AI_CHAT_MODEL=gpt-4o-mini
   ```

4. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

5. **Run the app**
   ```bash
   # iOS/Android
   flutter run

   # Web
   flutter run -d chrome

   # Desktop
   flutter run -d macos  # or windows, linux
   ```

### Supabase Setup

1. Create a new Supabase project
2. Run the migrations in `supabase/migrations/` folder
3. Enable Email/Password authentication
4. Configure Row Level Security (RLS) policies

---

## Architecture

```
lib/
├── config/           # App configuration
│   ├── constants.dart
│   ├── env.dart
│   ├── routes.dart
│   └── theme.dart
├── core/             # Core utilities
│   ├── cache/        # Caching layer
│   ├── error/        # Error handling
│   └── network/      # Network utilities
├── data/             # Data layer
│   ├── models/       # Data models
│   └── repositories/ # Data repositories
├── l10n/             # Localization (12 languages)
├── presentation/     # UI layer
│   ├── providers/    # Riverpod providers
│   ├── screens/      # App screens
│   └── widgets/      # Reusable widgets
└── services/         # Business logic
    ├── ai/           # AI provider abstraction
    ├── ai_service.dart
    ├── journal_pdf_service.dart
    ├── referral_service.dart
    └── trip_sharing_service.dart
```

### Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x |
| **State Management** | Riverpod |
| **Navigation** | go_router |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime) |
| **AI** | OpenAI API (with OpenRouter, Gemini support) |
| **Storage** | flutter_secure_storage, shared_preferences |
| **PDF** | pdf package |
| **Network** | Dio with retry handling |

### Key Design Patterns

- **Repository Pattern** - Clean data access abstraction
- **Provider Pattern** - Reactive state management with Riverpod
- **Service Layer** - Business logic separation
- **Offline-First** - Local caching with background sync

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | Yes |
| `OPENAI_API_KEY` | OpenAI API key | Yes |
| `OPENROUTER_API_KEY` | OpenRouter API key | No |
| `GOOGLE_AI_API_KEY` | Google Gemini API key | No |
| `AI_CHAT_PROVIDER` | AI provider (openai/openrouter/google) | No |
| `AI_CHAT_MODEL` | AI model name | No |

See `.env.example` for the complete list of configuration options.

---

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting a PR.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow

We use git worktrees for parallel feature development:
```bash
# Create a worktree for a new feature
git worktree add .trees/my-feature feature/my-feature

# Work in the worktree
cd .trees/my-feature

# Clean up when done
git worktree remove .trees/my-feature
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

**Nadav Chen** - Developer, Founder & CEO

- Website: [waylo.app](https://waylo.app)
- Email: support@waylo.app
- GitHub: [@Nadav23AnT](https://github.com/Nadav23AnT)

---

<p align="center">
  Made with :heart: for travelers worldwide
</p>
