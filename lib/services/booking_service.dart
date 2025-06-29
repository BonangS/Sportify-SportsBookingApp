import 'package:Sportify/models/booking_model.dart';
import 'package:Sportify/models/venue_model.dart';
import 'package:Sportify/services/supabase_service.dart';

class BookingService {
  static final _bookings = SupabaseService.client.from('bookings');

  static Future<List<BookingModel>> getUserBookings() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      final response = await _bookings
          .select('*, venues(*)')
          .eq('user_id', user.id)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((booking) => BookingModel.fromJson(booking))
          .toList();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  static Future<BookingModel?> getBookingById(String id) async {
    try {
      final response =
          await _bookings.select('*, venues(*)').eq('id', id).single();

      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error fetching booking: $e');
      return null;
    }
  }

  static Future<BookingModel?> createBooking({
    required String venueId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
    required double totalPrice,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) throw 'User not logged in';

      // Format booking_date as YYYY-MM-DD for the date field
      final formattedDate =
          "${bookingDate.year.toString()}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}";

      final booking = {
        'user_id': user.id,
        'venue_id': venueId,
        'booking_date': formattedDate,
        'start_time': startTime,
        'end_time': endTime,
        'total_price':
            totalPrice.toInt(), // Convert to int as required by schema
        'status': 'pending',
        'payment_status': 'paid', // Add payment status
      };

      final response =
          await _bookings.insert(booking).select('*, venues(*)').single();

      return BookingModel.fromJson(response);
    } catch (e) {
      print('Error creating booking: $e');
      // Re-throw the error so we can handle it properly in the UI
      rethrow;
    }
  }

  static Future<bool> updateBookingStatus(
    String bookingId,
    String status,
  ) async {
    try {
      await _bookings.update({'status': status}).eq('id', bookingId);
      return true;
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  static Future<List<String>> getBookedTimeSlots(
    String venueId,
    DateTime date,
  ) async {
    try {
      // Format date to YYYY-MM-DD to match Supabase date format
      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      // Query bookings for the specified venue and date
      // Using .or to get both 'confirmed' and 'pending' status bookings
      final response = await _bookings
          .select('start_time, end_time')
          .eq('venue_id', venueId)
          .eq('booking_date', formattedDate)
          .or('status.eq.confirmed,status.eq.pending');

      if ((response as List).isEmpty) {
        return [];
      }

      // Extract all booked hours from the time ranges
      final List<String> bookedSlots = [];
      for (final booking in response) {
        final startTime = booking['start_time'] as String;
        final endTime = booking['end_time'] as String;

        final startHour = int.parse(startTime.split(':')[0]);
        final endHour = int.parse(endTime.split(':')[0]);

        // Add all hours between start and end (inclusive of start, exclusive of end)
        // This correctly marks each hour slot as booked
        for (int hour = startHour; hour < endHour; hour++) {
          final timeSlot = '${hour.toString().padLeft(2, '0')}:00';
          if (!bookedSlots.contains(timeSlot)) {
            bookedSlots.add(timeSlot);
          }
        }
      }

      print('Booked slots for $formattedDate: $bookedSlots');
      return bookedSlots;
    } catch (e) {
      print('Error fetching booked time slots: $e');
      return [];
    }
  }

  static Future<int> countActiveBookings() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return 0;

      // Get all bookings for the current user
      final bookings = await getUserBookings();
      final now = DateTime.now();

      // Filter active bookings - same logic as in orders_screen.dart
      final activeBookings = bookings.where((booking) {
        // Convert booking time to a full DateTime for accurate comparison
        final bookingDate = booking.bookingDate;
        final endTimeComponents = booking.endTime.split(':');
        final endHour = int.parse(endTimeComponents[0]);
        final endMinute = int.parse(endTimeComponents[1]);

        final bookingEndDateTime = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
          endHour,
          endMinute,
        );

        // Active bookings:
        // 1. End time is in the future (including today's bookings)
        // 2. Status is not completed or cancelled
        return bookingEndDateTime.isAfter(now) &&
            booking.status != 'completed' &&
            booking.status != 'cancelled';
      });

      return activeBookings.length;
    } catch (e) {
      print('Error counting active bookings: $e');
      return 0;
    }
  }

  static Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return [];

      // Get current date in YYYY-MM-DD format
      final now = DateTime.now();
      final today =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Query for bookings that are today or in the future and not cancelled
      final response = await _bookings
          .select('*, venues(*)')
          .eq('user_id', user.id)
          .gte('booking_date', today) // Greater than or equal to today
          .not('status', 'eq', 'cancelled')
          .order('booking_date', ascending: true) // Sort by nearest date first
          .limit(3); // Only get the nearest 3 bookings for the home screen

      return (response as List)
          .map((booking) => BookingModel.fromJson(booking))
          .toList();
    } catch (e) {
      print('Error fetching upcoming bookings: $e');
      return [];
    }
  }
}
