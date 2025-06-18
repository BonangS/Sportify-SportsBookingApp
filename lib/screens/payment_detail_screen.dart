import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/utils/app_colors.dart';

class PaymentDetailScreen extends StatelessWidget {
  final Venue venue;
  final DateTime selectedDate;
  final List<String> selectedTimes;
  final int totalPrice;

  const PaymentDetailScreen({
    super.key,
    required this.venue,
    required this.selectedDate,
    required this.selectedTimes,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Format harga ke Rupiah
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Gabungkan jadwal yang dipilih menjadi string yang rapi
    // Contoh: "08:00, 09:00, 10:00"
    final scheduleString = selectedTimes.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembayaran'),
        backgroundColor: AppColors.background,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildBookingSummaryCard(scheduleString),
          const SizedBox(height: 24),
          _buildPriceDetailsCard(currencyFormatter),
          const SizedBox(height: 24),
          _buildPaymentMethodCard(),
        ],
      ),
      bottomNavigationBar: _buildConfirmButton(context),
    );
  }

  Widget _buildBookingSummaryCard(String scheduleString) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.grey, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(venue.address, style: const TextStyle(color: Colors.grey))),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal',
              value: DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(selectedDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.access_time_outlined,
              label: 'Jadwal',
              value: scheduleString,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetailsCard(NumberFormat currencyFormatter) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Biaya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${selectedTimes.length} jam x ${currencyFormatter.format(venue.pricePerHour)}'),
                Text(currencyFormatter.format(totalPrice)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  currencyFormatter.format(totalPrice),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Row(
              children: [
                const Text('Pilih', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade700),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ElevatedButton(
        onPressed: () {
          // Logika untuk konfirmasi pembayaran
          // Contoh: Tampilkan dialog sukses lalu kembali ke halaman utama
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Pembayaran Berhasil!'),
              content: const Text('Pesanan Anda telah dikonfirmasi.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); // Tutup dialog
                    Navigator.of(context).popUntil((route) => route.isFirst); // Kembali ke root
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text('Konfirmasi Pembayaran', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}