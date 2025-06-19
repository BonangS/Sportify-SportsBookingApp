import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/services/booking_service.dart';
import 'package:sport_application/models/booking_model.dart';
import 'package:sport_application/services/booking_update_service.dart';
import 'package:sport_application/services/notification_service.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  List<BookingModel> bookings = [];
  bool isLoading = true;
  StreamSubscription? _bookingUpdateSubscription;
  final _bookingUpdateService = BookingUpdateService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadBookings();
    WidgetsBinding.instance.addObserver(this);

    // Schedule a refresh when the screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadBookings();
    });

    // Subscribe to booking updates
    _bookingUpdateSubscription = _bookingUpdateService.onBookingUpdate.listen((
      _,
    ) {
      loadBookings();
    });
  }

  @override
  void dispose() {
    _bookingUpdateSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh bookings when app is resumed from background
      loadBookings();
    }
  }

  // Called when this screen becomes visible (e.g., after tab switch)
  void onScreenVisible() {
    loadBookings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when dependencies change (often happens when returning to this screen)
    loadBookings();
  }

  Future<void> loadBookings() async {
    if (!mounted) return;
    try {
      setState(() => isLoading = true);
      final userBookings = await BookingService.getUserBookings();
      if (mounted) {
        setState(() {
          bookings = userBookings;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading bookings: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<BookingModel> get activeBookings {
    final now = DateTime.now();
    return bookings.where((booking) {
      return booking.status != 'completed' &&
          booking.bookingDate.isAfter(now.subtract(const Duration(days: 1)));
    }).toList();
  }

  List<BookingModel> get historyBookings {
    final now = DateTime.now();
    return bookings.where((booking) {
      return booking.status == 'completed' ||
          booking.bookingDate.isBefore(now.subtract(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Must call super.build for AutomaticKeepAliveClientMixin
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(color: AppColors.textDark),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [Tab(text: 'Active'), Tab(text: 'History')],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: loadBookings,
                  child: TabBarView(
                    children: [
                      // Active Orders Tab
                      _buildBookingList(activeBookings),
                      // History Tab
                      _buildBookingList(historyBookings),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Text('Tidak ada pesanan', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final venueName = booking.venue?['name'] as String? ?? 'Venue Name';
        final venueImage = booking.venue?['image_url'] as String?;
        final formattedDate = DateFormat(
          'dd MMMM yyyy',
        ).format(booking.bookingDate);
        final formattedPrice = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp',
          decimalDigits: 0,
        ).format(booking.totalPrice);

        Color statusColor;
        switch (booking.status.toLowerCase()) {
          case 'pending':
            statusColor = Colors.orange;
            break;
          case 'confirmed':
            statusColor = Colors.green;
            break;
          case 'completed':
            statusColor = Colors.grey;
            break;
          case 'cancelled':
            statusColor = Colors.red;
            break;
          default:
            statusColor = Colors.grey;
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color:
                  booking.status.toLowerCase() == 'confirmed'
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
              width: 1,
            ),
          ),
          elevation: 2,
          child: Column(
            children: [
              if (venueImage != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    venueImage,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.sports,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            venueName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(booking.status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Booking info with icons
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${booking.startTime} - ${booking.endTime}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _calculateDuration(
                            booking.startTime,
                            booking.endTime,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.confirmation_number_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ID: ${booking.id.substring(0, 8)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Bottom section with price and action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedPrice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        if (booking.status.toLowerCase() == 'pending')
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Show confirmation dialog
                              final cancel = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Batalkan Pesanan'),
                                      content: const Text(
                                        'Apakah anda yakin ingin membatalkan pesanan ini?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Tidak'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Ya, Batalkan'),
                                        ),
                                      ],
                                    ),
                              );
                              if (cancel == true) {
                                await BookingService.updateBookingStatus(
                                  booking.id,
                                  'cancelled',
                                );

                                // Format date for notification
                                final formattedDate = DateFormat(
                                  'EEEE, d MMMM yyyy',
                                  'id_ID',
                                ).format(booking.bookingDate);
                                final timeSlot =
                                    '${booking.startTime} - ${booking.endTime}';
                                final venueName =
                                    booking.venue?['name'] as String? ??
                                    'Venue';

                                // Create cancellation notification
                                await NotificationService.addBookingCancelledNotification(
                                  venueName,
                                  formattedDate,
                                  timeSlot,
                                  booking.id,
                                );

                                loadBookings();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.close, size: 16),
                            label: const Text('Batalkan'),
                          ),

                        if (booking.status.toLowerCase() == 'confirmed')
                          OutlinedButton.icon(
                            onPressed: () {
                              // Show QR or ticket dialog
                              _showBookingTicket(context, booking);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                            ),
                            icon: const Icon(Icons.qr_code, size: 16),
                            label: const Text('Tiket'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to calculate duration between start and end time
  String _calculateDuration(String startTime, String endTime) {
    final startHour = int.parse(startTime.split(':')[0]);
    final endHour = int.parse(endTime.split(':')[0]);
    final durationHours = endHour - startHour;
    return '($durationHours jam)';
  }

  // Helper method to get a more user-friendly status text
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Terkonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  // Show booking ticket/QR dialog
  void _showBookingTicket(BuildContext context, BookingModel booking) {
    final venueName = booking.venue?['name'] as String? ?? 'Venue Name';
    final formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(booking.bookingDate);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'E-Tiket Booking',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.qr_code_2, size: 150, color: Colors.black87),
                        const SizedBox(height: 8),
                        Text(
                          booking.id,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ticketInfoRow('Lapangan', venueName),
                  _ticketInfoRow('Tanggal', formattedDate),
                  _ticketInfoRow(
                    'Waktu',
                    '${booking.startTime} - ${booking.endTime}',
                  ),
                  _ticketInfoRow(
                    'Status',
                    booking.status,
                    valueColor:
                        booking.status.toLowerCase() == 'confirmed'
                            ? Colors.green
                            : null,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Tunjukkan tiket ini kepada petugas lapangan',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Helper widget for ticket info rows
  Widget _ticketInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const Text(': '),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
