import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sport_application/config/supabase_config.dart';

class SupabaseService {
  static final client = Supabase.instance.client;
  
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: true, // Enable debug mode to see detailed logs
      );
      print('Supabase initialized successfully');
      await testConnection(); // Test connection after initialization
    } catch (e) {
      print('Error initializing Supabase: $e');
    }
  }

  static Future<void> testConnection() async {
    try {
      // Try to fetch data from users table
      final data = await client
          .from('users')
          .select();
      
      print('Test connection successful!');
      print('Data: $data');
    } catch (e) {
      print('Test connection failed: $e');
    }
  }

  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  
  // Database helpers
  static SupabaseQueryBuilder get users => client.from('users');
}
