// Supabase Edge Function for generating AI-powered daily travel tips
// Deploy with: supabase functions deploy generate-daily-tip
// Requires OPENAI_API_KEY environment variable

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface TripInfo {
  destination: string;
  start_date: string;
  end_date: string;
  status: string;
}

interface TipPayload {
  user_id: string;
  upcoming_trips: TripInfo[];
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Generate personalized travel tip using OpenAI
async function generateTip(trips: TripInfo[]): Promise<{ title: string; body: string }> {
  const openaiKey = Deno.env.get("OPENAI_API_KEY");
  if (!openaiKey) {
    console.error("OPENAI_API_KEY not configured");
    return getDefaultTip();
  }

  // Build context about user's trips
  let tripContext = "";
  if (trips && trips.length > 0) {
    const activeTrip = trips.find(t => t.status === "active");
    const planningTrip = trips.find(t => t.status === "planning");

    if (activeTrip) {
      tripContext = `The user is currently traveling to ${activeTrip.destination}. Generate a tip relevant to their current trip - could be about exploring, saving money while traveling, staying safe, making memories, or local customs.`;
    } else if (planningTrip) {
      tripContext = `The user is planning a trip to ${planningTrip.destination} starting on ${planningTrip.start_date}. Generate a preparation tip - could be about packing, researching, booking, or getting ready for the trip.`;
    }
  }

  if (!tripContext) {
    tripContext = "The user doesn't have any upcoming trips. Generate a general travel inspiration tip - could be about dreaming destinations, travel planning benefits, or motivation to book their next adventure.";
  }

  const systemPrompt = `You are Waylo, a friendly AI travel companion. Generate a short, actionable daily travel tip.

Rules:
- Keep the tip concise (max 2 sentences for the body)
- Be practical and actionable
- Use a warm, encouraging tone
- Include an emoji in the title
- Don't be generic - make it specific and useful
- Vary the topics: packing, budgeting, culture, safety, photography, food, planning, etc.

Format your response as JSON with "title" and "body" fields.
Example: {"title": "Pack Light, Travel Right! 🎒", "body": "Roll your clothes instead of folding to save 30% more space in your luggage."}`;

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${openaiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: tripContext },
        ],
        temperature: 0.9,
        max_tokens: 150,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error("OpenAI API error:", error);
      return getDefaultTip();
    }

    const result = await response.json();
    const content = result.choices[0]?.message?.content;

    if (content) {
      try {
        // Parse JSON response
        const parsed = JSON.parse(content);
        return {
          title: parsed.title || "Daily Travel Tip",
          body: parsed.body || content,
        };
      } catch {
        // If not valid JSON, use as body
        return {
          title: "Daily Travel Tip ✨",
          body: content.trim(),
        };
      }
    }

    return getDefaultTip();
  } catch (error) {
    console.error("Failed to generate tip:", error);
    return getDefaultTip();
  }
}

// Fallback tips if AI fails
function getDefaultTip(): { title: string; body: string } {
  const tips = [
    {
      title: "Save on Currency Exchange 💰",
      body: "Use a travel-friendly debit card to avoid foreign transaction fees and get better exchange rates.",
    },
    {
      title: "Pack a Power Strip 🔌",
      body: "One travel adapter + a power strip means you can charge all your devices at once.",
    },
    {
      title: "Take Photos of Signs 📸",
      body: "Snap a photo of your hotel name, metro stops, and street signs to navigate easier without data.",
    },
    {
      title: "Roll, Don't Fold! 🎒",
      body: "Rolling clothes instead of folding saves space and reduces wrinkles in your luggage.",
    },
    {
      title: "Eat Where Locals Eat 🍽️",
      body: "Restaurants full of locals usually offer better food at lower prices than tourist spots.",
    },
    {
      title: "Morning is Magic ☀️",
      body: "Visit popular attractions early morning - fewer crowds and better photos!",
    },
    {
      title: "Learn Three Phrases 🗣️",
      body: "Hello, Thank you, and Excuse me in the local language go a long way in any country.",
    },
    {
      title: "Email Yourself Copies 📧",
      body: "Send yourself photos of passport, insurance, and bookings as backup documents.",
    },
  ];

  return tips[Math.floor(Math.random() * tips.length)];
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

    const payload: TipPayload = await req.json();
    const { user_id, upcoming_trips } = payload;

    if (!user_id) {
      return new Response(
        JSON.stringify({ error: "user_id is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Generate personalized tip
    const tip = await generateTip(upcoming_trips || []);

    // Send push notification with the tip
    const { data: profile } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", user_id)
      .single();

    if (!profile?.fcm_token) {
      return new Response(
        JSON.stringify({ success: true, sent: false, reason: "no_fcm_token", tip }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Use the send-push-notification function internally
    // Call it via HTTP to reuse the FCM logic
    const pushResponse = await fetch(`${supabaseUrl}/functions/v1/send-push-notification`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${supabaseKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user_id,
        title: tip.title,
        body: tip.body,
        type: "daily_tip",
        data: {},
      }),
    });

    const pushResult = await pushResponse.json();

    return new Response(
      JSON.stringify({
        success: true,
        sent: pushResult.sent > 0,
        tip,
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
