import 'package:flutter/material.dart';
import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/widgets/schedule_grid.dart';
import 'package:sport_application/screens/payment_detail_screen.dart';

class DetailScreen extends StatelessWidget {
  final Venue venue;
  const DetailScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar yang bisa collapse
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                venue.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              background: Image.network(
                venue.imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
          ),

          // Konten di bawah gambar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info utama (Nama, Rating, Alamat)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${venue.rating}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          venue.address,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Fasilitas
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        venue.facilities
                            .map((facility) => Chip(label: Text(facility)))
                            .toList(),
                  ),
                  const Divider(height: 32),

                  // Jadwal
                  const Text(
                    'Pilih Tanggal & Jadwal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Placeholder untuk kalender
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selasa, 25 Desember 2023',
                        ), // Ini bisa diganti dengan date picker
                        Icon(Icons.calendar_today, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ScheduleGrid(),
                ],
              ),
            ),
          ),
        ],
      ),
      // Tombol Pesan Sekarang yang "sticky" di bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Harga', style: TextStyle(color: Colors.grey)),
                Text(
                  'Rp 150.000', // Ini nanti dihitung dinamis
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => PaymentDetailScreen(
                          venue: venue,
                          selectedDate:
                              DateTime.now(), // Ganti dengan tanggal yang dipilih user
                          selectedTimes: [
                            '08:00',
                          ], // Ganti dengan jadwal yang dipilih user
                          totalPrice:
                              150000, // Ganti dengan harga yang dihitung
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Pesan Sekarang'),
            ),
          ],
        ),
      ),
    );
  }
}
