import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/models/booking_model.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/services/booking_service.dart';
import 'package:sport_application/services/supabase_service.dart';
import 'package:sport_application/services/booking_update_service.dart';
import 'package:sport_application/services/notification_service.dart';

class PaymentDetailScreen extends StatefulWidget {
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
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  String paymentMethod = 'Virtual Account';
  // Fungsi untuk menyimpan booking ke Supabase
  Future<BookingModel?> _saveBooking() async {
    try {
      // Periksa user login
      if (SupabaseService.currentUser == null) {
        throw Exception('User not logged in');
      }

      // Konversi jam mulai dan jam selesai
      String startTime = widget.selectedTimes.first;
      String endTime = _calculateEndTime(widget.selectedTimes.last);

      print("Creating booking with venueId: ${widget.venue.id}");
      print("Booking date: ${widget.selectedDate}");
      print("Time range: $startTime - $endTime");
      print("Total price: ${widget.totalPrice}");

      // Gunakan BookingService untuk membuat booking
      final booking = await BookingService.createBooking(
        venueId: widget.venue.id,
        bookingDate: widget.selectedDate,
        startTime: startTime,
        endTime: endTime,
        totalPrice: widget.totalPrice.toDouble(),
      );

      if (booking == null) {
        throw Exception('Gagal membuat booking - null response');
      }

      print("Booking created with ID: ${booking.id}");

      return booking;
    } catch (e) {
      print('Error saving booking: $e');
      rethrow;
    }
  }

  // Fungsi untuk menghitung jam selesai (jam terakhir + 1 jam)
  String _calculateEndTime(String lastTime) {
    final parts = lastTime.split(':');
    int hour = int.parse(parts[0]);
    int nextHour = hour + 1;
    // Make sure we handle midnight wrapping correctly (unlikely for a sports venue, but just in case)
    if (nextHour >= 24) nextHour = 0;
    return nextHour.toString().padLeft(2, '0') + ':00';
  }

  // Format jadwal menjadi range jam
  String _formatTimeRange(List<String> times) {
    if (times.isEmpty) return '';

    // Urutkan waktu
    final sortedTimes = List<String>.from(times)..sort();

    // Ambil jam awal dan akhir
    final firstTime = sortedTimes.first;
    final lastTimeHour = int.parse(sortedTimes.last.split(':')[0]);
    final endTimeHour = lastTimeHour + 1;
    final endTime = '${endTimeHour.toString().padLeft(2, '0')}:00';

    // Hitung durasi yang benar berdasarkan selisih jam akhir dengan jam awal
    final startHour = int.parse(firstTime.split(':')[0]);
    // Durasi adalah selisih jam terakhir + 1 dengan jam awal
    final durationHours = endTimeHour - startHour;

    // Format "08:00 - 10:00 (2 jam)"
    return '$firstTime - $endTime ($durationHours jam)';
  }

  @override
  Widget build(BuildContext context) {
    // Format harga ke Rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );

    // Format jadwal sebagai range jam
    final scheduleString = _formatTimeRange(widget.selectedTimes);

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
              widget.venue.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.venue.address,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal',
              value: DateFormat(
                'EEEE, d MMMM yyyy',
                'id_ID',
              ).format(widget.selectedDate),
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
                Text(
                  '${widget.selectedTimes.length} jam x ${currencyFormatter.format(widget.venue.pricePerHour)}',
                ),
                Text(currencyFormatter.format(widget.totalPrice)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  currencyFormatter.format(widget.totalPrice),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Virtual Account
            _buildPaymentOption(
              'Virtual Account',
              Icons.account_balance,
              isSelected: paymentMethod == 'Virtual Account',
              onTap: () => setState(() => paymentMethod = 'Virtual Account'),
            ),
            const Divider(),

            // QRIS
            _buildPaymentOption(
              'QRIS',
              Icons.qr_code,
              isSelected: paymentMethod == 'QRIS',
              onTap: () => setState(() => paymentMethod = 'QRIS'),
            ),
            const Divider(),

            // Gopay
            _buildPaymentOption(
              'GoPay',
              Icons.g_mobiledata,
              subtitle: 'Rp 5.500',
              isSelected: paymentMethod == 'GoPay',
              onTap: () => setState(() => paymentMethod = 'GoPay'),
            ),
            const Divider(),

            // Alfamart
            _buildPaymentOption(
              'Alfamart',
              Icons.shopping_bag,
              subtitle: 'Rp 6.500',
              isSelected: paymentMethod == 'Alfamart',
              onTap: () => setState(() => paymentMethod = 'Alfamart'),
            ),
            const Divider(),

            // ShopeePay
            _buildPaymentOption(
              'ShopeePay',
              Icons.shopping_cart,
              subtitle: 'Rp 3.500',
              isSelected: paymentMethod == 'ShopeePay',
              onTap: () => setState(() => paymentMethod = 'ShopeePay'),
            ),
            const Divider(),

            // OVO
            _buildPaymentOption(
              'OVO',
              Icons.account_balance_wallet,
              subtitle: 'Rp 3.300',
              isSelected: paymentMethod == 'OVO',
              onTap: () => setState(() => paymentMethod = 'OVO'),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.lock, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Pembayaran Aman & Terenkripsi',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String title,
    IconData icon, {
    String? subtitle,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Icon(icon, color: Colors.grey.shade700)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: paymentMethod,
              activeColor: AppColors.primary,
              onChanged: (value) {
                if (value != null && onTap != null) {
                  onTap();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Secure Payment by Sportify',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Tampilkan loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (ctx) => const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Memproses pembayaran...'),
                        ],
                      ),
                    ),
              );
              try {
                print(
                  "Attempting to create booking with payment method: $paymentMethod",
                );

                // Simpan booking ke Supabase
                final booking = await _saveBooking();

                print("Booking created successfully: ${booking?.id}");

                // Tutup dialog loading
                Navigator.of(context).pop();

                if (booking != null) {
                  // Update status to confirmed immediately
                  await BookingService.updateBookingStatus(
                    booking.id,
                    'confirmed',
                  );

                  // Notify subscribers that a booking has been updated
                  BookingUpdateService().notifyBookingUpdate();

                  // Format tanggal untuk tampilan dan notifikasi
                  final dateFormatter = DateFormat(
                    'EEEE, d MMMM yyyy',
                    'id_ID',
                  );
                  final formattedDate = dateFormatter.format(
                    booking.bookingDate,
                  );

                  // Create success notification
                  await NotificationService.addPaymentSuccessNotification(
                    widget.venue.name,
                    formattedDate,
                    '${booking.startTime} - ${booking.endTime}',
                    booking.id,
                  );

                  // Tampilkan dialog sukses dengan detail booking
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Pembayaran Berhasil!'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pesanan Anda telah dikonfirmasi.'),
                              const SizedBox(height: 16),
                              const Text(
                                'Detail Booking:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text('Lapangan: ${widget.venue.name}'),
                              Text('Tanggal: $formattedDate'),
                              Text(
                                'Waktu: ${booking.startTime} - ${booking.endTime}',
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ID Booking: ${booking.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(ctx).pop(); // Close the dialog

                                // Navigate to Main screen with Orders tab (index 1)
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);

                                // Set the bottom nav to Orders tab (index 1)
                                // Also pass the booking ID to potentially highlight it
                                Navigator.of(context).pushReplacementNamed(
                                  '/main',
                                  arguments: {
                                    'initialTab': 1,
                                    'bookingId': booking.id,
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text('Lihat Pesanan Saya'),
                            ),
                          ],
                        ),
                  );
                }
              } catch (e) {
                // Tutup dialog loading
                Navigator.of(context).pop();

                print("Booking error occurred: $e");

                // Parse error message for better user experience
                String errorMessage = 'Gagal membuat pesanan';
                if (e.toString().contains('User not logged in')) {
                  errorMessage =
                      'Sesi Anda telah berakhir. Silakan login kembali.';
                } else if (e.toString().contains('network')) {
                  errorMessage =
                      'Gagal terhubung ke server. Periksa koneksi internet Anda.';
                } else if (e.toString().contains('duplicate')) {
                  errorMessage =
                      'Jadwal ini sudah dibooking. Silakan pilih jadwal lain.';
                } else if (e.toString().contains('socket')) {
                  errorMessage =
                      'Gagal terhubung ke server. Periksa koneksi internet Anda.';
                } else if (e.toString().contains('auth')) {
                  errorMessage = 'Silakan login kembali dan coba lagi.';
                } else {
                  errorMessage = 'Gagal membuat pesanan: ${e.toString()}';
                }

                // Tampilkan error
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Error'),
                        content: Text(errorMessage),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 60),
              elevation: 3,
              shadowColor: AppColors.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              minimumSize: const Size(double.infinity, 60),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_outlined, size: 26),
                SizedBox(width: 12),
                Text(
                  'Pay',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
