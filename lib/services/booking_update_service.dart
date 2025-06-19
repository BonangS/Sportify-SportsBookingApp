import 'dart:async';

/// Service to manage booking updates across the app
/// This is a simple singleton that can broadcast booking update events
class BookingUpdateService {
  // Singleton instance
  static final BookingUpdateService _instance =
      BookingUpdateService._internal();

  // Private constructor
  BookingUpdateService._internal();

  // Factory constructor to return the singleton instance
  factory BookingUpdateService() => _instance;

  // Stream controller for booking update events
  final _bookingUpdateController = StreamController<bool>.broadcast();

  // Stream getter
  Stream<bool> get onBookingUpdate => _bookingUpdateController.stream;

  // Method to notify listeners about a booking update
  void notifyBookingUpdate() {
    _bookingUpdateController.add(true);
  }

  // Dispose method to clean up resources
  void dispose() {
    _bookingUpdateController.close();
  }
}
