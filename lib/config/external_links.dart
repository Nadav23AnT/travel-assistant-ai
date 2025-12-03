import 'package:flutter_dotenv/flutter_dotenv.dart';

/// External links configuration for the app
/// All URLs are configurable via environment variables
class ExternalLinks {
  // App Store URLs
  static String get iosAppStoreUrl =>
      dotenv.env['IOS_APP_STORE_URL'] ?? 'https://apps.apple.com/app/waylo';

  static String get androidPlayStoreUrl =>
      dotenv.env['ANDROID_PLAY_STORE_URL'] ??
      'https://play.google.com/store/apps/details?id=com.waylo.app';

  // Get the appropriate app store URL based on platform
  static String get appStoreUrl {
    // For now, return iOS URL - can be platform-detected later
    return iosAppStoreUrl;
  }

  // Social Media URLs
  static String get instagramUrl =>
      dotenv.env['INSTAGRAM_URL'] ?? 'https://instagram.com/waylo_app';

  static String get twitterUrl =>
      dotenv.env['TWITTER_URL'] ?? 'https://twitter.com/waylo_app';

  static String get websiteUrl =>
      dotenv.env['WEBSITE_URL'] ?? 'https://waylo.app';

  // Share text template
  static String get shareAppText =>
      dotenv.env['SHARE_APP_TEXT'] ??
      'Check out Waylo - the ultimate travel companion app! Download now: ';

  // Referral/Invite link base
  static String get inviteLinkBase =>
      dotenv.env['INVITE_LINK_BASE'] ?? 'https://waylo.app/invite';
}
