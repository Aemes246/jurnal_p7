import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider {
  static const String fallbackUrl = 'https://rhxvilctefpprubwijsa.supabase.co';
  static const String fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJoeHZpbGN0ZWZwcHJ1YndpanNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY4ODA3NzEsImV4cCI6MjEwMjQ1Njc3MX0.DyEZjdOPgyWaDtfSiM5YUrJNwQTMBYEeSLiTWL1wtR4';

  static SupabaseClient? _rawClient;

  static String get effectiveUrl {
    final envUrl = dotenv.env['SUPABASE_URL'];
    return (envUrl != null && envUrl.isNotEmpty) ? envUrl : fallbackUrl;
  }

  static String get effectiveAnonKey {
    final envKey = dotenv.env['SUPABASE_ANON_KEY'];
    return (envKey != null && envKey.isNotEmpty) ? envKey : fallbackAnonKey;
  }

  static SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      try {
        _rawClient ??= SupabaseClient(effectiveUrl, effectiveAnonKey);
        return _rawClient;
      } catch (e) {
        debugPrint('Error creating fallback SupabaseClient: $e');
        return null;
      }
    }
  }

  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}

    final url = effectiveUrl;
    final anonKey = effectiveAnonKey;

    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
      );
      debugPrint('[SupabaseProvider] Supabase.initialize succeeded!');
    } catch (e) {
      debugPrint('[SupabaseProvider] Supabase.initialize failed, fallback to raw client: $e');
      _rawClient = SupabaseClient(url, anonKey);
    }
  }

  /// Direct REST HTTP GET fallback (guaranteed to work even if Flutter plugins fail on Web)
  static Future<List<Map<String, dynamic>>> restGet(
    String table, {
    String select = '*',
    Map<String, String>? queryParams,
  }) async {
    try {
      final query = <String, String>{'select': select};
      if (queryParams != null) query.addAll(queryParams);

      final uri = Uri.parse('$effectiveUrl/rest/v1/$table').replace(queryParameters: query);
      final res = await http.get(
        uri,
        headers: {
          'apikey': effectiveAnonKey,
          'Authorization': 'Bearer $effectiveAnonKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      } else {
        debugPrint('[SupabaseProvider] restGet $table failed: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('[SupabaseProvider] restGet $table exception: $e');
    }
    return [];
  }
}
