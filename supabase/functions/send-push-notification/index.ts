// Supabase Edge Function for sending push notifications via Firebase Cloud Messaging
// Deploy with: supabase functions deploy send-push-notification

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface NotificationPayload {
  user_id?: string;
  user_ids?: string[];
  title: string;
  body: string;
  data?: Record<string, string>;
  type?: string;
}

interface FCMMessage {
  message: {
    token: string;
    notification: {
      title: string;
      body: string;
    };
    data?: Record<string, string>;
    android?: {
      priority: string;
      notification: {
        channel_id: string;
        sound: string;
      };
    };
    apns?: {
      payload: {
        aps: {
          sound: string;
          badge: number;
        };
      };
    };
  };
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Get notification channel based on type
function getNotificationChannel(type?: string): string {
  switch (type) {
    case "trip_reminder":
    case "trip_status":
    case "weather_warning":
      return "waylo_trips";
    case "expense_reminder":
    case "budget_alert":
      return "waylo_expenses";
    case "journal_ready":
    case "journal_prompt":
      return "waylo_journal";
    case "support_reply":
    case "ticket_update":
      return "waylo_support";
    default:
      return "waylo_general";
  }
}

// Send notification to FCM
async function sendToFCM(
  fcmToken: string,
  title: string,
  body: string,
  data?: Record<string, string>,
  type?: string
): Promise<boolean> {
  const fcmServiceAccount = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!fcmServiceAccount) {
    console.error("FCM_SERVICE_ACCOUNT not configured");
    return false;
  }

  const serviceAccount = JSON.parse(fcmServiceAccount);
  const projectId = serviceAccount.project_id;

  // Get OAuth2 access token for FCM
  const accessToken = await getAccessToken(serviceAccount);
  if (!accessToken) {
    console.error("Failed to get FCM access token");
    return false;
  }

  const channelId = getNotificationChannel(type);

  const message: FCMMessage = {
    message: {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: {
        ...data,
        type: type || "general",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: "high",
        notification: {
          channel_id: channelId,
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    },
  };

  try {
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(message),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      console.error("FCM error:", error);
      return false;
    }

    const result = await response.json();
    console.log("FCM success:", result);
    return true;
  } catch (error) {
    console.error("FCM request failed:", error);
    return false;
  }
}

// Get OAuth2 access token for FCM
async function getAccessToken(
  serviceAccount: Record<string, string>
): Promise<string | null> {
  try {
    const now = Math.floor(Date.now() / 1000);
    const header = { alg: "RS256", typ: "JWT" };
    const payload = {
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    };

    // Create JWT
    const encoder = new TextEncoder();
    const headerB64 = btoa(JSON.stringify(header));
    const payloadB64 = btoa(JSON.stringify(payload));
    const signatureInput = `${headerB64}.${payloadB64}`;

    // Import private key and sign
    const privateKey = serviceAccount.private_key;
    const key = await crypto.subtle.importKey(
      "pkcs8",
      pemToArrayBuffer(privateKey),
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["sign"]
    );

    const signature = await crypto.subtle.sign(
      "RSASSA-PKCS1-v1_5",
      key,
      encoder.encode(signatureInput)
    );

    const signatureB64 = btoa(
      String.fromCharCode(...new Uint8Array(signature))
    )
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

    const jwt = `${headerB64}.${payloadB64}.${signatureB64}`;

    // Exchange JWT for access token
    const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
    });

    if (!tokenResponse.ok) {
      console.error("Token exchange failed:", await tokenResponse.text());
      return null;
    }

    const tokenData = await tokenResponse.json();
    return tokenData.access_token;
  } catch (error) {
    console.error("Failed to get access token:", error);
    return null;
  }
}

// Convert PEM to ArrayBuffer
function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const binaryString = atob(b64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
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

    const payload: NotificationPayload = await req.json();
    const { user_id, user_ids, title, body, data, type } = payload;

    if (!title || !body) {
      return new Response(
        JSON.stringify({ error: "Title and body are required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get target user IDs
    const targetUserIds = user_ids || (user_id ? [user_id] : []);
    if (targetUserIds.length === 0) {
      return new Response(
        JSON.stringify({ error: "user_id or user_ids is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get FCM tokens for all target users
    const { data: profiles, error: profileError } = await supabase
      .from("profiles")
      .select("id, fcm_token")
      .in("id", targetUserIds)
      .not("fcm_token", "is", null);

    if (profileError) {
      console.error("Failed to fetch profiles:", profileError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch user profiles" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!profiles || profiles.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          sent: 0,
          message: "No users with FCM tokens found",
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Check notification settings for each user
    const { data: notificationSettings } = await supabase
      .from("notification_settings")
      .select("user_id, master_enabled, push_notifications")
      .in(
        "user_id",
        profiles.map((p) => p.id)
      );

    const settingsMap = new Map(
      notificationSettings?.map((s) => [s.user_id, s]) || []
    );

    // Send notifications
    const results = await Promise.all(
      profiles.map(async (profile) => {
        const settings = settingsMap.get(profile.id);

        // Check if notifications are enabled
        if (settings && (!settings.master_enabled || !settings.push_notifications)) {
          return { user_id: profile.id, success: false, reason: "disabled" };
        }

        const success = await sendToFCM(
          profile.fcm_token,
          title,
          body,
          data,
          type
        );
        return { user_id: profile.id, success };
      })
    );

    const sent = results.filter((r) => r.success).length;
    const failed = results.filter((r) => !r.success && r.reason !== "disabled").length;
    const disabled = results.filter((r) => r.reason === "disabled").length;

    return new Response(
      JSON.stringify({
        success: true,
        sent,
        failed,
        disabled,
        total: targetUserIds.length,
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
