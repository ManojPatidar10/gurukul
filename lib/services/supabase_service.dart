import 'package:supabase_flutter/supabase_flutter.dart';

/// Reads credentials passed at build time, e.g.:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///                --dart-define=SUPABASE_ANON_KEY=xxxxx
/// Never hardcode the anon key directly in source for a real release —
/// use --dart-define or --dart-define-from-file so it isn't committed to git.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-ref.supabase.co',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-public-key',
  );
}

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
