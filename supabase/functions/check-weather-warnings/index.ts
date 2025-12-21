// Supabase Edge Function for checking weather warnings and sending alerts
// Deploy with: supabase functions deploy check-weather-warnings
// Schedule with pg_cron: SELECT cron.schedule('weather-check', '0 6 * * *', $$...$$);
//
// Required environment variables:
// - WEATHER_API_KEY: OpenWeatherMap API key
// - SUPABASE_URL: Auto-set by Supabase
// - SUPABASE_SERVICE_ROLE_KEY: Auto-set by Supabase

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface Trip {
  id: string;
  title: string;
  destination: string;
  destination_lat: number;
  destination_lng: number;
  owner_id: string;
}

interface WeatherAlert {
  event: string;
  sender_name: string;
  description: string;
  start: number;
  end: number;
}

interface WeatherResponse {
  alerts?: WeatherAlert[];
  current?: {
    temp: number;
    weather: Array<{ main: string; description: string }>;
  };
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Fetch weather data from OpenWeatherMap
async function getWeatherAlerts(
  lat: number,
  lng: number,
  apiKey: string
): Promise<WeatherAlert[]> {
  try {
    const url = `https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lng}&exclude=minutely,hourly,daily&appid=${apiKey}`;
    const response = await fetch(url);

    if (!response.ok) {
      console.error("Weather API error:", response.status);
      return [];
    }

    const data: WeatherResponse = await response.json();
    return data.alerts || [];
  } catch (error) {
    console.error("Failed to fetch weather:", error);
    return [];
  }
}

// Get severity level for an alert
function getAlertSeverity(event: string): "high" | "medium" | "low" {
  const highSeverity = [
    "tornado",
    "hurricane",
    "typhoon",
    "tsunami",
    "earthquake",
    "extreme",
    "severe",
  ];
  const mediumSeverity = [
    "warning",
    "storm",
    "flood",
    "fire",
    "heat",
    "cold",
    "wind",
  ];

  const eventLower = event.toLowerCase();

  if (highSeverity.some((s) => eventLower.includes(s))) {
    return "high";
  }
  if (mediumSeverity.some((s) => eventLower.includes(s))) {
    return "medium";
  }
  return "low";
}

// Send notification via the push notification function
async function sendWeatherNotification(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  tripId: string,
  tripTitle: string,
  destination: string,
  alerts: WeatherAlert[]
): Promise<boolean> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Get the most severe alert
  const sortedAlerts = alerts.sort((a, b) => {
    const severityOrder = { high: 0, medium: 1, low: 2 };
    return (
      severityOrder[getAlertSeverity(a.event)] -
      severityOrder[getAlertSeverity(b.event)]
    );
  });

  const primaryAlert = sortedAlerts[0];
  const severity = getAlertSeverity(primaryAlert.event);

  let title: string;
  let body: string;

  if (severity === "high") {
    title = `⚠️ SEVERE: ${primaryAlert.event}`;
    body = `Critical weather alert for your trip "${tripTitle}" to ${destination}. ${primaryAlert.description.substring(0, 100)}...`;
  } else if (severity === "medium") {
    title = `🌧️ Weather Warning: ${primaryAlert.event}`;
    body = `Weather alert for "${tripTitle}": ${primaryAlert.description.substring(0, 100)}...`;
  } else {
    title = `Weather Advisory for ${destination}`;
    body = `${primaryAlert.event}: ${primaryAlert.description.substring(0, 100)}...`;
  }

  try {
    const response = await fetch(
      `${supabaseUrl}/functions/v1/send-push-notification`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${serviceKey}`,
        },
        body: JSON.stringify({
          user_id: userId,
          title,
          body,
          type: "weather_warning",
          data: {
            id: tripId,
            alert_count: alerts.length.toString(),
            severity,
          },
        }),
      }
    );

    return response.ok;
  } catch (error) {
    console.error("Failed to send notification:", error);
    return false;
  }
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const weatherApiKey = Deno.env.get("WEATHER_API_KEY");
    if (!weatherApiKey) {
      console.error("WEATHER_API_KEY not configured");
      return new Response(
        JSON.stringify({ error: "Weather API key not configured" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Get active and upcoming trips with location data
    const today = new Date().toISOString().split("T")[0];
    const nextWeek = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      .toISOString()
      .split("T")[0];

    const { data: trips, error: tripsError } = await supabase
      .from("trips")
      .select(
        `
        id,
        title,
        destination,
        destination_lat,
        destination_lng,
        owner_id
      `
      )
      .in("status", ["planning", "active"])
      .not("destination_lat", "is", null)
      .not("destination_lng", "is", null)
      .or(`start_date.lte.${nextWeek},status.eq.active`);

    if (tripsError) {
      console.error("Failed to fetch trips:", tripsError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch trips" }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (!trips || trips.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "No trips to check",
          checked: 0,
          alerts_sent: 0,
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get notification settings for trip owners
    const ownerIds = [...new Set(trips.map((t: Trip) => t.owner_id))];
    const { data: settings } = await supabase
      .from("notification_settings")
      .select("user_id, master_enabled, push_notifications, weather_warnings")
      .in("user_id", ownerIds);

    const settingsMap = new Map(
      settings?.map((s) => [s.user_id, s]) || []
    );

    let checkedCount = 0;
    let alertsSent = 0;

    // Check weather for each trip
    for (const trip of trips as Trip[]) {
      const userSettings = settingsMap.get(trip.owner_id);

      // Skip if notifications disabled
      if (
        !userSettings ||
        !userSettings.master_enabled ||
        !userSettings.push_notifications ||
        !userSettings.weather_warnings
      ) {
        continue;
      }

      checkedCount++;

      // Get weather alerts for trip location
      const alerts = await getWeatherAlerts(
        trip.destination_lat,
        trip.destination_lng,
        weatherApiKey
      );

      if (alerts.length > 0) {
        const sent = await sendWeatherNotification(
          supabase,
          trip.owner_id,
          trip.id,
          trip.title,
          trip.destination,
          alerts
        );

        if (sent) {
          alertsSent++;
          console.log(
            `Weather alert sent for trip ${trip.id}: ${alerts.length} alerts`
          );
        }
      }

      // Rate limiting - wait 100ms between API calls
      await new Promise((resolve) => setTimeout(resolve, 100));
    }

    return new Response(
      JSON.stringify({
        success: true,
        checked: checkedCount,
        alerts_sent: alertsSent,
        total_trips: trips.length,
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
