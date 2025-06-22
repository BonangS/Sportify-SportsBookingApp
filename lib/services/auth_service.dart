import 'package:Sportify/models/user_model.dart';
import 'package:Sportify/services/supabase_service.dart';

class AuthService {
  static Future<UserModel?> getCurrentUser() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return null;

      final response =
          await SupabaseService.users.select().eq('id', user.id).single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String full_name,
    required String phone_number,
  }) async {
    try {
      // 1. Sign up with auth
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': full_name, 'phone_number': phone_number},
      );

      if (response.user == null) {
        throw 'Failed to create user account.';
      }

      // 2. Wait a bit to ensure auth is processed
      await Future.delayed(const Duration(milliseconds: 500));

      // 3. Create user profile
      final now = DateTime.now().toIso8601String();
      final userData = {
        'id': response.user!.id,
        'email': email,
        'full_name': full_name,
        'phone_number': phone_number,
        'created_at': now,
        'updated_at': now,
      };

      // 4. Insert into users table
      await SupabaseService.users.upsert(userData);

      // 5. Return user model
      return UserModel(
        id: response.user!.id,
        email: email,
        fullName: full_name,
        phoneNumber: phone_number,
        createdAt: DateTime.parse(now),
        updatedAt: DateTime.parse(now),
      );
    } catch (e) {
      print('Error during signup: $e');
      await SupabaseService.client.auth.signOut();
      throw e.toString();
    }
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userData =
            await SupabaseService.users
                .select()
                .eq('id', response.user!.id)
                .single();

        return UserModel.fromJson(userData);
      }
      throw 'Login failed';
    } catch (e) {
      print('Error during signin: $e');
      throw e.toString();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
  }) async {
    try {
      final updates = {
        if (fullName != null) 'full_name': fullName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (updates.isNotEmpty) {
        await SupabaseService.users.update(updates).eq('id', userId);
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw e.toString();
    }
  }
}
