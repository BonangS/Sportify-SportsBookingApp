import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/services/auth_service.dart';
import 'package:sport_application/services/supabase_service.dart';
import 'package:sport_application/services/booking_service.dart';
import 'package:sport_application/services/notification_service.dart';
import 'package:sport_application/models/user_model.dart';
import 'package:sport_application/models/notification_model.dart';
import 'package:sport_application/screens/login_screen_new.dart';
import 'package:sport_application/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isLoading = true;
  int activeBookingsCount = 0;
  List<NotificationModel> notifications = [];
  int unreadNotificationsCount = 0;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    loadNotifications(); // Listen for new notifications
    _notificationSubscription = NotificationService.notificationStream.listen((
      _,
    ) {
      loadNotifications();
      // If the notification might affect user data (like booking status), refresh the profile too
      loadUserProfile();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadUserProfile() async {
    try {
      setState(() => isLoading = true);
      final userProfile = await AuthService.getCurrentUser();
      final bookingCount = await BookingService.countActiveBookings();

      setState(() {
        user = userProfile;
        activeBookingsCount = bookingCount;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> loadNotifications() async {
    try {
      final notifs = await NotificationService.getUserNotifications();
      final unreadCount = await NotificationService.getUnreadCount();

      setState(() {
        notifications = notifs;
        unreadNotificationsCount = unreadCount;
      });
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  // Show notifications dialog
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await NotificationService.markAllAsRead();
                            // Simply update the UI counters
                            setState(() {
                              unreadNotificationsCount = 0;
                            });
                            Navigator.pop(context);
                            // Reload notifications to get the updated status
                            loadNotifications();
                          },
                          child: const Text(
                            'Tandai Semua Dibaca',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child:
                      notifications.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_off,
                                  size: 70,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada notifikasi',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: notifications.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];

                              // Choose icon based on notification type
                              IconData icon;
                              Color iconColor;

                              switch (notification.type) {
                                case 'payment':
                                  icon = Icons.payment;
                                  iconColor = Colors.green;
                                  break;
                                case 'cancellation':
                                  icon = Icons.cancel;
                                  iconColor = Colors.red;
                                  break;
                                default:
                                  icon = Icons.notifications;
                                  iconColor = AppColors.primary;
                              }
                              return InkWell(
                                onTap: () async {
                                  // Mark as read when tapped
                                  if (!notification.isRead) {
                                    await NotificationService.markAsRead(
                                      notification.id,
                                    );
                                    loadNotifications();
                                    // Update badge count in UI
                                    setState(() {
                                      if (unreadNotificationsCount > 0) {
                                        unreadNotificationsCount--;
                                      }
                                    });
                                  }

                                  // Navigate to relevant screen based on notification type
                                  if (notification.bookingId != null) {
                                    Navigator.of(context).pop(); // Close dialog
                                    // Navigate to Orders tab with the booking ID
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/main',
                                      (route) => false,
                                      arguments: {
                                        'initialTab': 1,
                                        'bookingId': notification.bookingId,
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  color:
                                      notification.isRead
                                          ? null
                                          : AppColors.primary.withOpacity(0.05),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: iconColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          icon,
                                          color: iconColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification.title,
                                              style: TextStyle(
                                                fontWeight:
                                                    notification.isRead
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notification.message,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notification.getRelativeTime(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            isLoading
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
                            backgroundImage:
                                user?.profilePictureUrl != null
                                    ? NetworkImage(user!.profilePictureUrl!)
                                    : null,
                            child:
                                user?.profilePictureUrl == null
                                    ? Text(
                                      user?.fullName
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          '?',
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
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32), // Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context: context,
                              icon: Icons.calendar_today,
                              value: activeBookingsCount.toString(),
                              label: 'Total Booking Aktif',
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
                        onTap: () async {
                          if (user != null) {
                            // Navigate to Edit Profile screen
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => EditProfileScreen(user: user!),
                              ),
                            );

                            // If changes were made, refresh the profile
                            if (result == true) {
                              loadUserProfile();
                            }
                          }
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.notifications,
                        label: 'Notifikasi',
                        badge:
                            unreadNotificationsCount > 0
                                ? (unreadNotificationsCount > 9
                                    ? '9+'
                                    : unreadNotificationsCount.toString())
                                : null,
                        onTap: () {
                          _showNotificationsDialog(context);
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
                          // Tampilkan dialog konfirmasi
                          bool confirm =
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Konfirmasi"),
                                    content: const Text(
                                      "Apakah Anda yakin ingin keluar?",
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Batal"),
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "Ya",
                                          style: TextStyle(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (confirm) {
                            try {
                              await SupabaseService.client.auth.signOut();
                              // Navigasi ke login screen dengan import
                              if (context.mounted) {
                                // Import LoginScreen terlebih dahulu di bagian atas file
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const LoginScreenNew(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              print('Error signing out: $e');
                            }
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
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Center(
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
