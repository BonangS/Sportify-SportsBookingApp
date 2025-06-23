import 'package:flutter/material.dart';
import 'package:Sportify/models/venue_model.dart';
import 'package:Sportify/utils/app_colors.dart';
import 'package:Sportify/screens/payment_detail_screen.dart';
import 'package:Sportify/services/booking_service.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  final Venue venue;
  const DetailScreen({super.key, required this.venue});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DateTime selectedDate = DateTime.now(); // Define time slots as ranges
  final List<Map<String, String>> timeSlotRanges = [
    {'start': '08:00', 'end': '09:00'},
    {'start': '09:00', 'end': '10:00'},
    {'start': '10:00', 'end': '11:00'},
    {'start': '11:00', 'end': '12:00'},
    {'start': '12:00', 'end': '13:00'},
    {'start': '13:00', 'end': '14:00'},
    {'start': '14:00', 'end': '15:00'},
    {'start': '15:00', 'end': '16:00'},
    {'start': '16:00', 'end': '17:00'},
    {'start': '17:00', 'end': '18:00'},
    {'start': '18:00', 'end': '19:00'},
    {'start': '19:00', 'end': '20:00'},
    {'start': '20:00', 'end': '21:00'},
  ];
  List<Map<String, String>> selectedTimeSlots = [];
  List<String> bookedTimeSlots = [];
  bool isLoading = true;

  // Calculate correct duration based on the number of selected slots
  int get totalHours {
    if (selectedTimeSlots.isEmpty) return 0;
    // Simply return the number of selected slots
    return selectedTimeSlots.length;
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

  // Sort time slots by start time
  void _sortTimeSlots() {
    selectedTimeSlots.sort((a, b) => a['start']!.compareTo(b['start']!));
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
          itemCount: timeSlotRanges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Reduced to 3 for better fit of time ranges
            crossAxisSpacing: 10,
            mainAxisSpacing: 16,
            childAspectRatio:
                1.6, // Adjusted for better appearance with time ranges
          ),
          itemBuilder: (context, index) {
            final timeSlot = timeSlotRanges[index];
            final startTime = timeSlot['start']!;
            final endTime = timeSlot['end']!;
            final displayText =
                '${startTime.substring(0, 5)}-${endTime.substring(0, 5)}';

            // Check if this slot is already selected
            final isSelected = selectedTimeSlots.contains(timeSlot);

            // Check if the start time of this slot is in the booked list
            final isBooked = bookedTimeSlots.contains(startTime);
            
            // Check if this slot is in the past (for today only)
            bool isPastTime = false;
            if (selectedDate.year == DateTime.now().year && 
                selectedDate.month == DateTime.now().month && 
                selectedDate.day == DateTime.now().day) {
              // Parse time slot start hour
              final int slotHour = int.parse(startTime.split(':')[0]);
              // If slot hour is earlier than current hour, mark as past
              if (slotHour <= DateTime.now().hour) {
                isPastTime = true;
              }
            }

            // Visual state of the tile
            Color bgColor = Colors.white;
            Color borderColor = Colors.grey.shade300;
            Color textColor = Colors.black87;
            List<BoxShadow>? boxShadow;
            double opacity = 1.0;

            // Determine visual state based on selection, booking status, and past time
            if (isBooked || isPastTime) {
              bgColor = Colors.grey.shade200;
              borderColor = Colors.grey.shade400;
              textColor = Colors.grey;
              opacity = 0.5;
            } else if (isSelected) {
              bgColor = AppColors.primary;
              borderColor = AppColors.primary;
              textColor = Colors.white;
              boxShadow = [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ];
            }

            return GestureDetector(
              onTap:
                  isBooked || isPastTime
                      ? null // Disable tap for booked slots and past time slots
                      : () {
                        setState(() {
                          if (isSelected) {
                            // Remove the time slot and cleanup any disconnected slots
                            selectedTimeSlots.remove(timeSlot);
                            _cleanupDisconnectedSlots();
                          } else {
                            // Check if the slot creates a consecutive sequence
                            if (_isConsecutiveTimeRange(timeSlot)) {
                              selectedTimeSlots.add(timeSlot);
                              _sortTimeSlots(); // Keep slots sorted
                            } else {
                              // Show error message for non-consecutive selection
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Silakan pilih slot waktu yang berurutan',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        });
                      },
              child: Opacity(
                opacity: opacity,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: boxShadow,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "1 jam",
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      if (isBooked)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Icon(Icons.block, color: Colors.red, size: 14),
                        ),
                      if (isPastTime && !isBooked)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Icon(Icons.access_time, color: Colors.grey, size: 14),
                        ),
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

  // Function to check if a time slot is consecutive to the existing selection
  bool _isConsecutiveTimeRange(Map<String, String> timeSlot) {
    if (selectedTimeSlots.isEmpty) return true;

    // Helper function to extract hour from time string
    int getHour(String time) {
      return int.parse(time.split(':')[0]);
    }

    // Get the new slot's hour
    int newStartHour = getHour(timeSlot['start']!);

    // Sort current slots
    List<Map<String, String>> sortedSlots = List.from(selectedTimeSlots);
    sortedSlots.sort(
      (a, b) => getHour(a['start']!).compareTo(getHour(b['start']!)),
    );

    // Get min and max hours from current selection
    int minHour = getHour(sortedSlots.first['start']!);
    int maxHour = getHour(sortedSlots.last['end']!) - 1;

    // New slot should connect to either start or end of the current range
    return newStartHour == minHour - 1 || newStartHour == maxHour + 1;
  }

  // Method to clean up time slots when one is removed to maintain a valid continuous range
  void _cleanupDisconnectedSlots() {
    if (selectedTimeSlots.isEmpty) return;

    // Helper function to extract hour from time string
    int getHour(String time) {
      return int.parse(time.split(':')[0]);
    }

    // Sort by start time
    _sortTimeSlots();

    // Find connected time slots
    List<Map<String, String>> connectedSlots = [];
    Map<String, String> firstSlot = selectedTimeSlots.first;
    connectedSlots.add(firstSlot);

    int lastEndHour = getHour(firstSlot['end']!);

    for (int i = 1; i < selectedTimeSlots.length; i++) {
      int currentStartHour = getHour(selectedTimeSlots[i]['start']!);
      if (currentStartHour == lastEndHour) {
        connectedSlots.add(selectedTimeSlots[i]);
        lastEndHour = getHour(selectedTimeSlots[i]['end']!);
      } else {
        // Found a gap, stop adding
        break;
      }
    }

    // Update selected slots to just include the connected ones
    selectedTimeSlots = connectedSlots;
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
                        // Convert the selected time slots to the format expected by the payment screen
                        List<String> selectedStartTimes =
                            selectedTimeSlots
                                .map((slot) => slot['start']!)
                                .toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => PaymentDetailScreen(
                                  venue: widget.venue,
                                  selectedDate: selectedDate,
                                  selectedTimes: selectedStartTimes,
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
