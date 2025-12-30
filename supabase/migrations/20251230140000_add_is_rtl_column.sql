-- Add is_rtl column to admin_notifications table
-- This allows admins to explicitly set text direction for notifications

ALTER TABLE admin_notifications
ADD COLUMN IF NOT EXISTS is_rtl BOOLEAN DEFAULT false;

-- Add comment for documentation
COMMENT ON COLUMN admin_notifications.is_rtl IS 'Whether the notification text should be displayed right-to-left (for Hebrew/Arabic content)';
