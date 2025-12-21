// Supabase Edge Function for sending support-related email notifications
// Deploy with: supabase functions deploy send-support-email
// Requires RESEND_API_KEY environment variable

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface EmailPayload {
  user_id: string;
  type: "support_reply" | "ticket_created" | "ticket_status_changed" | "ticket_resolved";
  session_id: string;
  subject?: string;
  message?: string;
  new_status?: string;
}

interface UserProfile {
  id: string;
  email: string;
  full_name: string | null;
}

interface NotificationSettings {
  master_enabled: boolean;
  email_notifications: boolean;
  support_reply_notifications: boolean;
  ticket_status_updates: boolean;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Email templates for different notification types
function getEmailContent(
  type: EmailPayload["type"],
  userName: string,
  subject: string,
  message?: string,
  newStatus?: string
): { htmlBody: string; textBody: string; emailSubject: string } {
  const appName = "Waylo";
  const supportEmail = "support@waylo.app";

  switch (type) {
    case "support_reply":
      return {
        emailSubject: `Re: ${subject} - New Reply from Waylo Support`,
        htmlBody: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Support Reply</title>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 16px 16px 0 0; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 24px;">New Support Reply</h1>
    </div>
    <div style="background-color: white; padding: 30px; border-radius: 0 0 16px 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
      <p style="color: #333; font-size: 16px; line-height: 1.6;">Hi ${userName},</p>
      <p style="color: #333; font-size: 16px; line-height: 1.6;">We've replied to your support ticket:</p>
      <div style="background-color: #f8f9fa; border-left: 4px solid #667eea; padding: 15px; margin: 20px 0; border-radius: 4px;">
        <strong style="color: #667eea;">${subject}</strong>
      </div>
      ${message ? `
      <div style="background-color: #f0f4ff; padding: 20px; border-radius: 8px; margin: 20px 0;">
        <p style="color: #333; font-size: 14px; line-height: 1.6; margin: 0;">${message}</p>
      </div>
      ` : ""}
      <div style="text-align: center; margin-top: 30px;">
        <a href="https://waylo.app/support" style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-decoration: none; padding: 14px 30px; border-radius: 8px; font-weight: 600;">View Full Conversation</a>
      </div>
      <p style="color: #666; font-size: 14px; line-height: 1.6; margin-top: 30px;">
        Thank you for using ${appName}!<br>
        The Waylo Support Team
      </p>
    </div>
    <div style="text-align: center; padding: 20px; color: #999; font-size: 12px;">
      <p>You're receiving this because you have email notifications enabled for support updates.</p>
      <p>Manage your notification preferences in the Waylo app settings.</p>
    </div>
  </div>
</body>
</html>`,
        textBody: `Hi ${userName},

We've replied to your support ticket: "${subject}"

${message ? `Reply: ${message}` : ""}

View the full conversation in the Waylo app.

Thank you for using ${appName}!
The Waylo Support Team`,
      };

    case "ticket_created":
      return {
        emailSubject: `Support Ticket Created: ${subject}`,
        htmlBody: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 30px; border-radius: 16px 16px 0 0; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 24px;">Ticket Received</h1>
    </div>
    <div style="background-color: white; padding: 30px; border-radius: 0 0 16px 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
      <p style="color: #333; font-size: 16px; line-height: 1.6;">Hi ${userName},</p>
      <p style="color: #333; font-size: 16px; line-height: 1.6;">We've received your support request and our team is on it!</p>
      <div style="background-color: #f8f9fa; border-left: 4px solid #10b981; padding: 15px; margin: 20px 0; border-radius: 4px;">
        <strong style="color: #10b981;">${subject}</strong>
      </div>
      <p style="color: #666; font-size: 14px; line-height: 1.6;">We typically respond within 24 hours. You'll receive a notification when we reply.</p>
      <div style="text-align: center; margin-top: 30px;">
        <a href="https://waylo.app/support" style="display: inline-block; background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; text-decoration: none; padding: 14px 30px; border-radius: 8px; font-weight: 600;">View Ticket</a>
      </div>
      <p style="color: #666; font-size: 14px; line-height: 1.6; margin-top: 30px;">
        Thank you for reaching out!<br>
        The Waylo Support Team
      </p>
    </div>
  </div>
</body>
</html>`,
        textBody: `Hi ${userName},

We've received your support request and our team is on it!

Subject: ${subject}

We typically respond within 24 hours. You'll receive a notification when we reply.

Thank you for reaching out!
The Waylo Support Team`,
      };

    case "ticket_status_changed":
      const statusEmoji =
        newStatus === "in_progress" ? "🔄" : newStatus === "closed" ? "📋" : "📌";
      const statusText =
        newStatus === "in_progress"
          ? "In Progress"
          : newStatus === "closed"
          ? "Closed"
          : newStatus;
      return {
        emailSubject: `Ticket Update: ${subject} - ${statusText}`,
        htmlBody: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); padding: 30px; border-radius: 16px 16px 0 0; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 24px;">${statusEmoji} Ticket Status Updated</h1>
    </div>
    <div style="background-color: white; padding: 30px; border-radius: 0 0 16px 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
      <p style="color: #333; font-size: 16px; line-height: 1.6;">Hi ${userName},</p>
      <p style="color: #333; font-size: 16px; line-height: 1.6;">Your support ticket status has been updated:</p>
      <div style="background-color: #f8f9fa; border-left: 4px solid #f59e0b; padding: 15px; margin: 20px 0; border-radius: 4px;">
        <strong style="color: #f59e0b;">${subject}</strong>
        <p style="margin: 10px 0 0 0; color: #666;">New Status: <strong>${statusText}</strong></p>
      </div>
      <div style="text-align: center; margin-top: 30px;">
        <a href="https://waylo.app/support" style="display: inline-block; background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: white; text-decoration: none; padding: 14px 30px; border-radius: 8px; font-weight: 600;">View Ticket</a>
      </div>
    </div>
  </div>
</body>
</html>`,
        textBody: `Hi ${userName},

Your support ticket "${subject}" status has been updated to: ${statusText}

View the ticket in the Waylo app for more details.

The Waylo Support Team`,
      };

    case "ticket_resolved":
      return {
        emailSubject: `Ticket Resolved: ${subject}`,
        htmlBody: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; margin: 0; padding: 0; background-color: #f5f5f5;">
  <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
    <div style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 30px; border-radius: 16px 16px 0 0; text-align: center;">
      <h1 style="color: white; margin: 0; font-size: 24px;">Ticket Resolved</h1>
    </div>
    <div style="background-color: white; padding: 30px; border-radius: 0 0 16px 16px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
      <p style="color: #333; font-size: 16px; line-height: 1.6;">Hi ${userName},</p>
      <p style="color: #333; font-size: 16px; line-height: 1.6;">Great news! Your support ticket has been resolved:</p>
      <div style="background-color: #f0fdf4; border-left: 4px solid #10b981; padding: 15px; margin: 20px 0; border-radius: 4px;">
        <strong style="color: #10b981;">${subject}</strong>
      </div>
      <p style="color: #666; font-size: 14px; line-height: 1.6;">If you have any more questions or if the issue persists, feel free to reopen the ticket or create a new one.</p>
      <div style="text-align: center; margin-top: 30px;">
        <a href="https://waylo.app/support" style="display: inline-block; background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; text-decoration: none; padding: 14px 30px; border-radius: 8px; font-weight: 600;">View Ticket</a>
      </div>
      <p style="color: #666; font-size: 14px; line-height: 1.6; margin-top: 30px;">
        Thank you for using ${appName}!<br>
        The Waylo Support Team
      </p>
    </div>
  </div>
</body>
</html>`,
        textBody: `Hi ${userName},

Great news! Your support ticket has been resolved:

Subject: ${subject}

If you have any more questions or if the issue persists, feel free to reopen the ticket or create a new one.

Thank you for using ${appName}!
The Waylo Support Team`,
      };

    default:
      return {
        emailSubject: `Support Update: ${subject}`,
        htmlBody: `<p>Hi ${userName}, there's an update on your support ticket.</p>`,
        textBody: `Hi ${userName}, there's an update on your support ticket: ${subject}`,
      };
  }
}

// Send email using Resend API
async function sendEmail(
  to: string,
  subject: string,
  htmlBody: string,
  textBody: string
): Promise<boolean> {
  const resendApiKey = Deno.env.get("RESEND_API_KEY");
  if (!resendApiKey) {
    console.error("RESEND_API_KEY not configured");
    return false;
  }

  try {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "Waylo Support <support@waylo.app>",
        to: [to],
        subject,
        html: htmlBody,
        text: textBody,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error("Resend API error:", error);
      return false;
    }

    const result = await response.json();
    console.log("Email sent:", result);
    return true;
  } catch (error) {
    console.error("Email send failed:", error);
    return false;
  }
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const payload: EmailPayload = await req.json();
    const { user_id, type, session_id, subject, message, new_status } = payload;

    if (!user_id || !type || !session_id) {
      return new Response(
        JSON.stringify({ error: "user_id, type, and session_id are required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get user profile
    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("id, email, full_name")
      .eq("id", user_id)
      .single();

    if (profileError || !profile) {
      console.error("Failed to fetch profile:", profileError);
      return new Response(
        JSON.stringify({ error: "User not found" }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get user email from auth
    const { data: authData } = await supabase.auth.admin.getUserById(user_id);
    const userEmail = authData?.user?.email;

    if (!userEmail) {
      return new Response(
        JSON.stringify({ error: "User email not found" }),
        {
          status: 404,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Check notification settings
    const { data: settings } = await supabase
      .from("notification_settings")
      .select("master_enabled, email_notifications, support_reply_notifications, ticket_status_updates")
      .eq("user_id", user_id)
      .single();

    if (settings) {
      const notificationSettings = settings as NotificationSettings;

      // Check if email notifications are enabled
      if (!notificationSettings.master_enabled || !notificationSettings.email_notifications) {
        return new Response(
          JSON.stringify({ success: true, sent: false, reason: "email_disabled" }),
          {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      // Check specific notification type
      if (type === "support_reply" && !notificationSettings.support_reply_notifications) {
        return new Response(
          JSON.stringify({ success: true, sent: false, reason: "support_reply_disabled" }),
          {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      if ((type === "ticket_status_changed" || type === "ticket_resolved") &&
          !notificationSettings.ticket_status_updates) {
        return new Response(
          JSON.stringify({ success: true, sent: false, reason: "status_updates_disabled" }),
          {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }
    }

    // Get session subject if not provided
    let ticketSubject = subject;
    if (!ticketSubject) {
      const { data: session } = await supabase
        .from("support_sessions")
        .select("subject")
        .eq("id", session_id)
        .single();
      ticketSubject = session?.subject || "Support Ticket";
    }

    // Generate email content
    const userName = (profile as UserProfile).full_name || "there";
    const emailContent = getEmailContent(
      type,
      userName,
      ticketSubject,
      message,
      new_status
    );

    // Send the email
    const sent = await sendEmail(
      userEmail,
      emailContent.emailSubject,
      emailContent.htmlBody,
      emailContent.textBody
    );

    return new Response(
      JSON.stringify({ success: true, sent }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
