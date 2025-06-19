import 'package:flutter/material.dart';
import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/screens/payment_detail_screen.dart';
import 'package:sport_application/services/booking_service.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Venue venue;
  const DetailScreen({super.key, required this.venue});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DateTime selectedDate = DateTime.now();
  final List<String> availableTimeSlots = [
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];
  List<String> selectedTimeSlots = [];
  List<String> bookedTimeSlots = [];
  bool isLoading = true;

  // Calculate correct duration based on the range (not the number of slots)
  int get totalHours {
    if (selectedTimeSlots.isEmpty) return 0;

    // Sort slots
    List<String> sortedSlots = List.from(selectedTimeSlots)..sort();

    // Calculate the range (end hour - start hour)
    int startHour = int.parse(sortedSlots.first.split(':')[0]);
    int lastHour = int.parse(sortedSlots.last.split(':')[0]);

    // Calculate the correct duration: (last hour + 1) - start hour
    // This gives us 2 hours for 8:00-10:00, not 3 hours
    int endHour = lastHour + 1;
    return endHour - startHour;
  }

  int get totalPrice => totalHours * widget.venue.pricePerHour;

  @override
  void initState() {
    super.initState();
    _fetchBookedSlots();
  }

  // Method to fetch booked slots
  Future<void> _fetchBookedSlots() async {
    setState(() {
      isLoading = true;
    });

    try {
      final slots = await BookingService.getBookedTimeSlots(
        widget.venue.id,
        selectedDate,
      );

      setState(() {
        bookedTimeSlots = slots;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching booked slots: $e');
      setState(() {
        bookedTimeSlots = [];
        isLoading = false;
      });
    }
  }

  // Widget untuk memilih tanggal (7 hari ke depan)
  Widget _buildDatePicker() {
    final now = DateTime.now();
    final dates = List.generate(7, (index) => now.add(Duration(days: index)));

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedTimeSlots = []; // Reset ketika tanggal berubah
              });
              // Fetch new booked slots for the selected date
              _fetchBookedSlots();
            },
            child: Container(
              width: 65,
              margin: EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade300,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget untuk memilih slot waktu
  Widget _buildTimeSlots() {
    // Currency formatter untuk format harga
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pilih Jam',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableTimeSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 2.0,
          ),
          itemBuilder: (context, index) {
            final time = availableTimeSlots[index];
            final isSelected = selectedTimeSlots.contains(time);
            final isBooked = bookedTimeSlots.contains(time);

            return GestureDetector(
              onTap:
                  isBooked
                      ? null
                      : () {
                        setState(() {
                          if (isSelected) {
                            // Remove the time slot and any disconnected slots
                            selectedTimeSlots.remove(time);
                            _cleanupDisconnectedSlots();
                          } else {
                            // Pastikan slot yang dipilih berurutan
                            if (_isConsecutiveSlot(time)) {
                              selectedTimeSlots.add(time);
                              selectedTimeSlots.sort(); // Urutkan slot
                            } else {
                              // Tampilkan pesan error jika tidak berurutan
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Silakan pilih slot waktu yang berurutan',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        });
                      },
              child: Opacity(
                opacity: isBooked ? 0.5 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppColors.primary
                            : isBooked
                            ? Colors.grey.shade200
                            : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.primary
                              : isBooked
                              ? Colors.grey.shade400
                              : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow:
                        isSelected && !isBooked
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                            : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color:
                              isSelected
                                  ? Colors.white
                                  : isBooked
                                  ? Colors.grey
                                  : Colors.black87,
                        ),
                      ),
                      if (isBooked)
                        const Icon(Icons.block, color: Colors.red, size: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Menampilkan jumlah jam dan total harga
        if (selectedTimeSlots.isNotEmpty) ...[
          const Divider(height: 32),
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Durasi:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$totalHours jam',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Harga:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        currencyFormatter.format(totalPrice),
                        style: TextStyle(
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
          ),
        ],
      ],
    );
  }

  // Fungsi untuk memastikan slot waktu yang dipilih membentuk rentang yang valid
  bool _isConsecutiveSlot(String timeSlot) {
    if (selectedTimeSlots.isEmpty) return true;

    // Get the hour as integer
    int getHour(String time) {
      return int.parse(time.split(':')[0]);
    }

    final newHour = getHour(timeSlot);

    // Sort current slots to find min and max hours
    if (selectedTimeSlots.isNotEmpty) {
      List<String> sortedSlots = List.from(selectedTimeSlots)..sort();
      int minHour = getHour(sortedSlots.first);
      int maxHour = getHour(sortedSlots.last);

      // Allow if the new slot is before the minimum or after the maximum
      if (newHour < minHour || newHour > maxHour) {
        return true;
      }

      // Allow if the slot is within the current range (even if not consecutive)
      if (newHour > minHour && newHour < maxHour) {
        return true;
      }
    }

    return false;
  }

  // Method to clean up time slots when one is removed to maintain valid ranges
  void _cleanupDisconnectedSlots() {
    if (selectedTimeSlots.isEmpty) return;

    // We don't need to enforce consecutive slots anymore
    // Instead, we'll just keep all selected slots
    // The price calculation will be based on the range
  }

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
                widget.venue.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Image.network(
                widget.venue.imageUrl ??
                    'https://via.placeholder.com/800x400?text=No+Image',
                fit: BoxFit.cover,
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
                  // Alamat & Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.venue.address,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.venue.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Harga per jam
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(widget.venue.pricePerHour),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(
                          text: ' / jam',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Fasilitas
                  const SizedBox(height: 24),
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children:
                        widget.venue.facilities
                            .map((facility) => Chip(label: Text(facility)))
                            .toList(),
                  ),
                  const Divider(height: 32), // Jadwal
                  const Text(
                    'Pilih Tanggal & Jadwal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Date Picker Horizontal
                  _buildDatePicker(),
                  const SizedBox(height: 24),
                  // Time Slots Grid
                  _buildTimeSlots(),
                ],
              ),
            ),
          ),
        ],
      ), // Tombol Pesan Sekarang yang "sticky" di bawah
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
                const Text('Total Harga', style: TextStyle(color: Colors.grey)),
                Text(
                  selectedTimeSlots.isEmpty
                      ? 'Pilih jadwal'
                      : NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 2,
                      ).format(totalPrice),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed:
                  selectedTimeSlots.isEmpty
                      ? null
                      : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PaymentDetailScreen(
                                  venue: widget.venue,
                                  selectedDate: selectedDate,
                                  selectedTimes: selectedTimeSlots,
                                  totalPrice: totalPrice,
                                ),
                          ),
                        );
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Pesan Sekarang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
