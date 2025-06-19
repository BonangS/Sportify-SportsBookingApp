import 'package:flutter/material.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/services/booking_service.dart';
import 'package:sport_application/models/booking_model.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<BookingModel> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      setState(() => isLoading = true);
      final userBookings = await BookingService.getUserBookings();
      setState(() {
        bookings = userBookings;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading bookings: $e');
      setState(() => isLoading = false);
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
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: isLoading
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
        child: Text(
          'Tidak ada pesanan',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final venueName = booking.venue?['name'] as String? ?? 'Venue Name';
        final venueImage = booking.venue?['image_url'] as String?;
        final formattedDate = DateFormat('dd MMMM yyyy').format(booking.bookingDate);
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
          child: Column(
            children: [
              if (venueImage != null)
                Image.network(
                  venueImage,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          venueName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                            booking.status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${booking.startTime} - ${booking.endTime}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (booking.status.toLowerCase() == 'pending')
                          TextButton(
                            onPressed: () async {
                              // Show confirmation dialog
                              final cancel = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Batalkan Pesanan'),
                                  content: const Text(
                                    'Apakah anda yakin ingin membatalkan pesanan ini?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Tidak'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Ya'),
                                    ),
                                  ],
                                ),
                              );

                              if (cancel == true) {
                                await BookingService.updateBookingStatus(
                                  booking.id,
                                  'cancelled',
                                );
                                loadBookings();
                              }
                            },
                            child: const Text(
                              'Batalkan',
                              style: TextStyle(color: Colors.red),
                            ),
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
}
