import 'package:flutter/material.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/services/auth_service.dart';
import 'package:sport_application/services/supabase_service.dart';
import 'package:sport_application/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      setState(() => isLoading = true);
      final userProfile = await AuthService.getCurrentUser();
      setState(() {
        user = userProfile;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadUserProfile,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: user?.profilePictureUrl != null
                            ? NetworkImage(user!.profilePictureUrl!)
                            : null,
                        child: user?.profilePictureUrl == null
                            ? Text(
                                user?.fullName?.substring(0, 1).toUpperCase() ?? '?',
                                style: const TextStyle(fontSize: 24),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'User',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.phoneNumber ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.calendar_today,
                          value: '12',
                          label: 'Total Booking',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: Icons.star,
                          value: '4.8',
                          label: 'Rating',
                        ),
                      ),
                    ],
                  ),

                  // Menu Items
                  const SizedBox(height: 32),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.edit,
                    label: 'Edit Profil',
                    onTap: () {
                      // TODO: Implement edit profile
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.notifications,
                    label: 'Notifikasi',
                    onTap: () {
                      // TODO: Implement notifications
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.help,
                    label: 'Bantuan',
                    onTap: () {
                      // TODO: Implement help
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.logout,
                    label: 'Keluar',
                    onTap: () async {
                      try {
                        await SupabaseService.client.auth.signOut();
                        // Navigate to login screen
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      } catch (e) {
                        print('Error signing out: $e');
                      }
                    },
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
