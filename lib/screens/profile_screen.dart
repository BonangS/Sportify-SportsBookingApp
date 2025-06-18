import 'package:flutter/material.dart';
import 'package:sport_application/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Header
            const Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1633332755192-727a05c4013d?q=80&w=2080&auto=format&fit=crop',
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budi Santoso',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '+62 812-3456-7890',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Pesanan',
                    '12',
                    Icons.receipt_long,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Pembayaran',
                    'Rp 2.4jt',
                    Icons.payment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Menu Items
            _buildMenuItem(
              'Edit Profile',
              Icons.person_outline,
              onTap: () {},
            ),
            _buildMenuItem(
              'Metode Pembayaran',
              Icons.credit_card,
              onTap: () {},
            ),
            _buildMenuItem(
              'Pengaturan Notifikasi',
              Icons.notifications_none,
              onTap: () {},
            ),
            _buildMenuItem(
              'Pusat Bantuan',
              Icons.help_outline,
              onTap: () {},
            ),
            _buildMenuItem(
              'Syarat dan Ketentuan',
              Icons.description_outlined,
              onTap: () {},
            ),
            _buildMenuItem(
              'Tentang Aplikasi',
              Icons.info_outline,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            
            // Logout Button
            OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
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
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
