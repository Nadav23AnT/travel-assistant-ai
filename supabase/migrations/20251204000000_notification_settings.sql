-- Notification Settings Table
-- Comprehensive notification preferences for all notification types

CREATE TABLE IF NOT EXISTS notification_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Master control
  master_enabled BOOLEAN DEFAULT true,

  -- General notifications
  push_notifications BOOLEAN DEFAULT true,
  email_notifications BOOLEAN DEFAULT true,

  -- Do Not Disturb
  dnd_enabled BOOLEAN DEFAULT false,
  dnd_start_time TIME DEFAULT '22:00:00',
  dnd_end_time TIME DEFAULT '07:00:00',
  dnd_active_days INTEGER[] DEFAULT ARRAY[1,2,3,4,5,6,7], -- 1=Monday to 7=Sunday

  -- Trip notifications
  trip_reminders BOOLEAN DEFAULT true,
  trip_reminder_days_before INTEGER DEFAULT 3,
  trip_status_changes BOOLEAN DEFAULT true,
  weather_warnings BOOLEAN DEFAULT true,
  daily_trip_summary BOOLEAN DEFAULT true,
  daily_trip_summary_time TIME DEFAULT '20:00:00',

  -- Expense & Budget notifications
  expense_reminder BOOLEAN DEFAULT true,
  expense_reminder_time TIME DEFAULT '20:00:00',
  budget_alerts BOOLEAN DEFAULT true,
  budget_alert_threshold DECIMAL(3,2) DEFAULT 0.90,
  weekly_spending_summary BOOLEAN DEFAULT true,

  -- Journal & Memories notifications
  journal_ready BOOLEAN DEFAULT true,
  daily_journal_prompt BOOLEAN DEFAULT false,
  daily_journal_time TIME DEFAULT '21:00:00',

  -- App & Engagement notifications
  rate_app_reminder BOOLEAN DEFAULT true,
  new_feature_announcements BOOLEAN DEFAULT true,
  tips_and_recommendations BOOLEAN DEFAULT true,

  -- Support notifications
  support_reply_notifications BOOLEAN DEFAULT true,
  ticket_status_updates BOOLEAN DEFAULT true,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(user_id)
);

-- Add FCM token storage to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMPTZ;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_notification_settings_user_id ON notification_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token ON profiles(fcm_token) WHERE fcm_token IS NOT NULL;

-- Enable RLS
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view own notification settings"
  ON notification_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification settings"
  ON notification_settings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification settings"
  ON notification_settings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notification settings"
  ON notification_settings FOR DELETE
  USING (auth.uid() = user_id);

-- Function to auto-create notification settings for new users
CREATE OR REPLACE FUNCTION create_notification_settings_for_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO notification_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create notification settings when profile is created
DROP TRIGGER IF EXISTS create_notification_settings_trigger ON profiles;
CREATE TRIGGER create_notification_settings_trigger
  AFTER INSERT ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION create_notification_settings_for_user();

-- Create notification settings for existing users
INSERT INTO notification_settings (user_id)
SELECT id FROM profiles
WHERE id NOT IN (SELECT user_id FROM notification_settings)
ON CONFLICT (user_id) DO NOTHING;

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_notification_settings_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS notification_settings_updated_at ON notification_settings;
CREATE TRIGGER notification_settings_updated_at
  BEFORE UPDATE ON notification_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_notification_settings_timestamp();
