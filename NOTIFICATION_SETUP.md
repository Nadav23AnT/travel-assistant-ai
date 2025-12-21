# Notification System Setup Guide

This guide covers how to configure and enable all notification features for the Waylo app.

## Prerequisites

Before enabling notifications, ensure you have:

1. **Supabase Project** with the migrations applied
2. **Firebase Project** with FCM configured
3. **API Keys** for external services (weather, email)

---

## Step 1: Apply Database Migrations

Run the following migrations in order:

```bash
# Core notification settings (already applied)
supabase db push

# Or apply migrations manually in Supabase SQL Editor
```

**Migrations included:**
- `20251204000000_notification_settings.sql` - Base settings table
- `20251205000000_scheduled_notifications.sql` - Scheduled notification functions
- `20251205000001_notification_triggers.sql` - Event-driven triggers

---

## Step 2: Enable Required Extensions

In your Supabase Dashboard → Database → Extensions, enable:

- [x] `pg_net` - For HTTP requests from database functions
- [x] `pg_cron` - For scheduled jobs (requires Pro plan or self-hosted)

---

## Step 3: Configure Environment Variables

### Supabase Secrets

Set the following secrets in Supabase Dashboard → Settings → Edge Functions:

```bash
# Required for push notifications (already configured)
FCM_SERVICE_ACCOUNT={"type":"service_account","project_id":"..."}

# Required for weather warnings (Phase 9)
WEATHER_API_KEY=your_openweathermap_api_key

# Required for email notifications (Phase 10)
RESEND_API_KEY=re_xxxxxxxxxxxxx
```

### Getting API Keys

1. **OpenWeatherMap API Key**
   - Sign up at https://openweathermap.org/api
   - Subscribe to "One Call API 3.0"
   - Copy your API key

2. **Resend API Key**
   - Sign up at https://resend.com
   - Create an API key
   - Verify your sending domain

---

## Step 4: Deploy Edge Functions

```bash
# Deploy all notification-related functions
supabase functions deploy send-push-notification
supabase functions deploy check-weather-warnings
supabase functions deploy send-email
```

---

## Step 5: Enable Scheduled Jobs (pg_cron)

After enabling `pg_cron` extension, run these SQL commands to enable scheduled notifications:

```sql
-- Trip reminders: Daily at 9 AM UTC
SELECT cron.schedule(
    'trip-reminders',
    '0 9 * * *',
    $$SELECT public.send_trip_reminders()$$
);

-- Daily trip summaries: Every hour (checks user's configured time)
SELECT cron.schedule(
    'daily-trip-summaries',
    '0 * * * *',
    $$SELECT public.send_daily_trip_summaries()$$
);

-- Expense reminders: Every hour (checks user's configured time)
SELECT cron.schedule(
    'expense-reminders',
    '0 * * * *',
    $$SELECT public.send_expense_reminders()$$
);

-- Daily journal prompts: Every hour (checks user's configured time)
SELECT cron.schedule(
    'daily-journal-prompts',
    '0 * * * *',
    $$SELECT public.send_daily_journal_prompts()$$
);

-- Weekly spending summary: Sundays at 10 AM UTC
SELECT cron.schedule(
    'weekly-spending-summaries',
    '0 10 * * 0',
    $$SELECT public.send_weekly_spending_summaries()$$
);

-- Rate app reminders: Daily at 12 PM UTC
SELECT cron.schedule(
    'rate-app-reminders',
    '0 12 * * *',
    $$SELECT public.send_rate_app_reminders()$$
);

-- Journal ready check: Daily at 10 AM UTC
SELECT cron.schedule(
    'journal-ready-notifications',
    '0 10 * * *',
    $$SELECT public.send_journal_ready_notifications()$$
);

-- Weather warnings: Daily at 6 AM UTC
SELECT cron.schedule(
    'weather-warnings',
    '0 6 * * *',
    $$SELECT net.http_post(
        url := current_setting('app.settings.supabase_url') || '/functions/v1/check-weather-warnings',
        headers := jsonb_build_object(
            'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
        )
    )$$
);
```

### Managing Cron Jobs

```sql
-- View all scheduled jobs
SELECT * FROM cron.job;

-- Disable a job
SELECT cron.unschedule('trip-reminders');

-- View job history
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 20;
```

---

## Step 6: Configure App Settings for Database Functions

The scheduled notification functions need access to your Supabase URL and service key to call edge functions. Set these in your Supabase project:

**Option A: Using Vault (Recommended)**

```sql
-- Store secrets in Vault
SELECT vault.create_secret('your-supabase-url', 'supabase_url');
SELECT vault.create_secret('your-service-role-key', 'service_role_key');
```

**Option B: Using App Settings**

```sql
-- Set as database config (less secure but simpler)
ALTER DATABASE postgres SET app.settings.supabase_url = 'https://your-project.supabase.co';
ALTER DATABASE postgres SET app.settings.service_role_key = 'your-service-role-key';
```

---

## Feature Checklist

| Feature | Status | Requirements |
|---------|--------|--------------|
| Push Notifications | ✅ Ready | FCM configured |
| Support Reply Alerts | ✅ Ready | Auto-triggers on admin messages |
| Budget Alerts | ✅ Ready | Auto-triggers on new expenses |
| Trip Status Changes | ✅ Ready | Auto-triggers on status update |
| Trip Reminders | ⏳ Needs pg_cron | Enable scheduled job |
| Daily Summaries | ⏳ Needs pg_cron | Enable scheduled job |
| Expense Reminders | ⏳ Needs pg_cron | Enable scheduled job |
| Journal Prompts | ⏳ Needs pg_cron | Enable scheduled job |
| Weekly Summaries | ⏳ Needs pg_cron | Enable scheduled job |
| Weather Warnings | ⏳ Needs API key | Set WEATHER_API_KEY |
| Email Notifications | ⏳ Needs API key | Set RESEND_API_KEY |

---

## Testing

### Test Push Notification

```bash
curl -X POST 'https://your-project.supabase.co/functions/v1/send-push-notification' \
  -H 'Authorization: Bearer your-anon-key' \
  -H 'Content-Type: application/json' \
  -d '{
    "user_id": "test-user-uuid",
    "title": "Test Notification",
    "body": "This is a test",
    "type": "general"
  }'
```

### Test Email

```bash
curl -X POST 'https://your-project.supabase.co/functions/v1/send-email' \
  -H 'Authorization: Bearer your-service-role-key' \
  -H 'Content-Type: application/json' \
  -d '{
    "to": "test@example.com",
    "template": "welcome",
    "data": {"user_name": "Test User"}
  }'
```

### Test Weather Check

```bash
curl -X POST 'https://your-project.supabase.co/functions/v1/check-weather-warnings' \
  -H 'Authorization: Bearer your-service-role-key'
```

---

## Troubleshooting

### Notifications not sending?

1. Check FCM_SERVICE_ACCOUNT is set correctly
2. Verify user has FCM token stored in profiles table
3. Check notification_settings for user has master_enabled=true

### Cron jobs not running?

1. Verify pg_cron extension is enabled
2. Check job is scheduled: `SELECT * FROM cron.job`
3. Check job history: `SELECT * FROM cron.job_run_details`

### Emails not sending?

1. Verify RESEND_API_KEY is set
2. Check sending domain is verified in Resend
3. Check notification_settings.email_notifications is enabled for user

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Flutter App                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ NotificationSvc │  │ Settings Screen │  │ Deep Link Nav   │  │
│  └────────┬────────┘  └────────┬────────┘  └────────┬────────┘  │
└───────────┼─────────────────────┼─────────────────────┼─────────┘
            │                     │                     │
            ▼                     ▼                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Supabase                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    notification_settings                     ││
│  │  (user preferences, DND schedule, thresholds)               ││
│  └─────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐       │
│  │  DB Triggers  │  │   pg_cron     │  │ Edge Functions│       │
│  │ (Phase 8)     │  │ (Phase 7)     │  │ (Phase 9/10)  │       │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘       │
└──────────┼──────────────────┼──────────────────┼────────────────┘
           │                  │                  │
           └──────────────────┼──────────────────┘
                              ▼
                    ┌─────────────────┐
                    │ send-push-notif │
                    │ Edge Function   │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │   Firebase FCM  │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  User's Device  │
                    └─────────────────┘
```
