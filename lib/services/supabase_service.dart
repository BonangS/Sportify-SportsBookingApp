import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Sportify/config/supabase_config.dart';

class SupabaseService {
  static final client = Supabase.instance.client;
  static const String _bucketName =
      'images'; // Menggunakan nama bucket "images"

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
      final data = await client.from('users').select();

      print('Test connection successful!');
      print('Data: $data');
    } catch (e) {
      print('Test connection failed: $e');
    }
  }

  // logout
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Auth helpers
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;

  // Database helpers
  static SupabaseQueryBuilder get users => client.from('users');
  // Storage helpers for profile pictures
  static Future<String> uploadProfilePicture(
    String filePath,
    String userId,
  ) async {
    try {
      // Validate the input file
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('File does not exist at path: $filePath');
      }

      final fileExt = filePath.split('.').last.toLowerCase();
      final fileName = 'profile_$userId.$fileExt';

      // Check if we're authenticated
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Starting file upload to bucket: $_bucketName');
      debugPrint(
        'File info - Path: $filePath, Size: ${file.lengthSync()} bytes',
      );

      // Check if file already exists and remove it first
      try {
        await client.storage.from(_bucketName).remove(['$fileName']);
        debugPrint('Removed existing profile picture');
      } catch (e) {
        // File likely doesn't exist, which is fine
        debugPrint('No existing profile picture found or could not remove: $e');
      }

      // Upload file to 'images' bucket
      final uploadResult = await client.storage
          .from(_bucketName)
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true, // Use upsert to overwrite if exists
            ),
          );

      debugPrint('Upload result: $uploadResult');

      // Get public URL for the uploaded image
      final imageUrl = client.storage.from(_bucketName).getPublicUrl(fileName);
      debugPrint('Uploaded image URL: $imageUrl');

      return imageUrl;
    } catch (e, stack) {
      debugPrint('Error uploading profile picture: $e');
      debugPrint('Stack trace: $stack');
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
