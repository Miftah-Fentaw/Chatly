import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static SupabaseClient? _client;


  

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");

      final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim();
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();

      debugPrint('Supabase URL: ${supabaseUrl != null ? '✓' : '✗'}');
      debugPrint('Supabase Anon Key: ${supabaseAnonKey != null ? '✓' : '✗'}');

      if (supabaseUrl == null || supabaseUrl.isEmpty) {
        throw Exception('Missing SUPABASE_URL in .env file');
      }

      if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
        throw Exception('Missing SUPABASE_ANON_KEY in .env file');
      }

      debugPrint('Initializing Supabase...');
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization failed: $e');
    }
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first or connect from Dreamflow panel.');
    }
    return _client!;
  }

  static bool get isInitialized => _client != null;



  
}
