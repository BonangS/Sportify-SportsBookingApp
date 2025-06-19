import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'payment', 'booking', 'cancellation', etc.
  final DateTime timestamp;
  final bool isRead;
  final String? bookingId; // Optional reference to a booking

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.bookingId,
  });

  // Factory constructor to create a notification from a Supabase map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      type: map['type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['is_read'] as bool,
      bookingId: map['booking_id'] as String?,
    );
  }

  // Convert to a map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'booking_id': bookingId,
    };
  }

  // Helper method to format the relative time (e.g., "2 hours ago")
  String getRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
