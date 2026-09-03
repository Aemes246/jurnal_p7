import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider {
  static const String fallbackUrl = 'https://rhxvilctefpprubwijsa.supabase.co';
  static const String fallbackAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJoeHZpbGN0ZWZwcHJ1YndpanNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4ODA3NzEsImV4cCI6MjEwMjQ1Njc3MX0.DyEZjdOPgyWaDtfSiM5YUrJNwQTMBYEeSLiTWL1wtR4';

  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}

    final url = dotenv.env['SUPABASE_URL'] ?? fallbackUrl;
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? fallbackAnonKey;

    try {
      await Supabase.initialize(
        url: url.isNotEmpty ? url : fallbackUrl,
        publishableKey: anonKey.isNotEmpty ? anonKey : fallbackAnonKey,
      );
    } catch (_) {}
  }
}
