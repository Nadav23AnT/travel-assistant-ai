// Supabase Edge Function for sending admin broadcast notifications
// This function creates the notification record and sends FCM push notifications to all users
// Deploy with: supabase functions deploy send-admin-broadcast

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface BroadcastPayload {
  title: string;
  message: string;
  priority?: "normal" | "important" | "urgent";
  deep_link?: string;
  action_button_text?: string;
  auto_dismiss_hours?: number;
  is_rtl?: boolean;
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // Create admin client with service role
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Get user's JWT from Authorization header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Create client with user's JWT to check admin status
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const supabaseUser = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    // Verify user is authenticated
    const {
      data: { user },
      error: userError,
    } = await supabaseUser.auth.getUser();

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Check if user is admin by querying profiles table
    const { data: profile, error: profileError } = await supabaseAdmin
      .from("profiles")
      .select("is_admin")
      .eq("id", user.id)
      .single();

    if (profileError || !profile?.is_admin) {
      return new Response(
        JSON.stringify({ error: "Admin access required" }),
        {
          status: 403,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Parse request payload
    const payload: BroadcastPayload = await req.json();
    const {
      title,
      message,
      priority = "normal",
      deep_link,
      action_button_text = "View Details",
      auto_dismiss_hours = 48,
      is_rtl = false
    } = payload;

    // Validate required fields
    if (!title || !message) {
      return new Response(
        JSON.stringify({ error: "Title and message are required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validate field lengths
    if (title.length > 60) {
      return new Response(
        JSON.stringify({ error: "Title must be 60 characters or less" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (message.length > 500) {
      return new Response(
        JSON.stringify({ error: "Message must be 500 characters or less" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validate priority
    if (!["normal", "important", "urgent"].includes(priority)) {
      return new Response(
        JSON.stringify({
          error: "Priority must be normal, important, or urgent",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Validate auto_dismiss_hours
    if (auto_dismiss_hours < 1 || auto_dismiss_hours > 720) {
      return new Response(
        JSON.stringify({
          error: "Auto dismiss hours must be between 1 and 720",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Create the notification in the database using admin client
    const { data: notification, error: notificationError } = await supabaseAdmin
      .from("admin_notifications")
      .insert({
        title,
        message,
        priority,
        deep_link: deep_link || null,
        action_button_text: action_button_text || "View Details",
        sent_by: user.id,
        auto_dismiss_hours,
        is_rtl,
      })
      .select()
      .single();

    if (notificationError) {
      console.error("Failed to create notification:", notificationError);
      return new Response(
        JSON.stringify({ error: "Failed to create notification" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get all user IDs from profiles
    const { data: profiles, error: profilesError } = await supabaseAdmin
      .from("profiles")
      .select("id");

    if (profilesError) {
      console.error("Failed to fetch profiles:", profilesError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch user profiles" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const userIds = profiles?.map((p) => p.id) || [];

    // Create user_notification records for all users
    if (userIds.length > 0) {
      const userNotifications = userIds.map((userId) => ({
        user_id: userId,
        notification_id: notification.id,
      }));

      const { error: insertError } = await supabaseAdmin
        .from("user_notifications")
        .insert(userNotifications);

      if (insertError) {
        console.error("Failed to create user notifications:", insertError);
        // Don't fail completely, notification was created
      }
    }

    // Send FCM push notifications to all users with tokens
    const { data: usersWithTokens } = await supabaseAdmin
      .from("profiles")
      .select("id, fcm_token")
      .not("fcm_token", "is", null);

    let pushSent = 0;
    let pushFailed = 0;
    let pushDisabled = 0;

    if (usersWithTokens && usersWithTokens.length > 0) {
      // Call the existing send-push-notification function
      const pushPayload = {
        user_ids: usersWithTokens.map((u) => u.id),
        title,
        body: message,
        type: "admin_broadcast",
        data: {
          notification_id: notification.id,
          priority,
          deep_link: deep_link || "",
        },
      };

      try {
        const pushResponse = await fetch(
          `${supabaseUrl}/functions/v1/send-push-notification`,
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${supabaseServiceKey}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify(pushPayload),
          }
        );

        if (pushResponse.ok) {
          const pushResult = await pushResponse.json();
          pushSent = pushResult.sent || 0;
          pushFailed = pushResult.failed || 0;
          pushDisabled = pushResult.disabled || 0;
        } else {
          console.error(
            "Push notification failed:",
            await pushResponse.text()
          );
        }
      } catch (pushError) {
        console.error("Failed to send push notifications:", pushError);
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        notification_id: notification.id,
        sent_count: userIds.length,
        push_notifications: {
          sent: pushSent,
          failed: pushFailed,
          disabled: pushDisabled,
        },
      }),
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
