-- Settings Expansion Migration
-- Adds new columns to user_settings for full settings screen

-- Date and display preferences
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS date_format TEXT DEFAULT 'DD/MM/YYYY';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS distance_unit TEXT DEFAULT 'km';
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS dark_mode BOOLEAN DEFAULT false;

-- Privacy settings
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS share_analytics BOOLEAN DEFAULT true;
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS location_tracking BOOLEAN DEFAULT true;

-- Notification settings (push_notifications distinct from email)
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS push_notifications BOOLEAN DEFAULT true;
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS trip_reminders BOOLEAN DEFAULT true;

-- Add constraints for date_format
ALTER TABLE user_settings DROP CONSTRAINT IF EXISTS user_settings_date_format_check;
ALTER TABLE user_settings ADD CONSTRAINT user_settings_date_format_check
  CHECK (date_format IN ('DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'));

-- Add constraints for distance_unit
ALTER TABLE user_settings DROP CONSTRAINT IF EXISTS user_settings_distance_unit_check;
ALTER TABLE user_settings ADD CONSTRAINT user_settings_distance_unit_check
  CHECK (distance_unit IN ('km', 'mi'));
