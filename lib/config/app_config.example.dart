// Copy this file to app_config.dart and fill in your credentials.
// Supabase: supabase.com → your project → Settings → API
// Google Web Client ID: console.cloud.google.com → APIs & Services → Credentials
// Anthropic: console.anthropic.com → API Keys (needed for AI plan generation)
class AppConfig {
  static const supabaseUrl       = 'https://YOUR_PROJECT_ID.supabase.co';
  static const supabaseAnonKey   = 'YOUR_ANON_KEY';
  static const googleWebClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  // Leave empty to disable AI plan generation.
  static const anthropicApiKey = '';
}
