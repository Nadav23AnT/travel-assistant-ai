import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // AI Providers
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openrouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get googleAiApiKey => dotenv.env['GOOGLE_AI_API_KEY'] ?? '';

  // Google Maps
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // RevenueCat
  static String get revenuecatApiKey => dotenv.env['REVENUECAT_API_KEY'] ?? '';
  static String get revenuecatAppleApiKey => dotenv.env['REVENUECAT_APPLE_API_KEY'] ?? '';
  static String get revenuecatGoogleApiKey => dotenv.env['REVENUECAT_GOOGLE_API_KEY'] ?? '';

  // Validation helpers
  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasOpenAI => openaiApiKey.isNotEmpty;
  static bool get hasGoogleMaps => googleMapsApiKey.isNotEmpty;
}
