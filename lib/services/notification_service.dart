import 'dart:async';
import 'package:sport_application/models/notification_model.dart';
import 'package:sport_application/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class NotificationService {
  static final StreamController<NotificationModel> _notificationController =
      StreamController<NotificationModel>.broadcast();

  // Stream untuk real-time notifications
  static Stream<NotificationModel> get notificationStream =>
      _notificationController.stream;
  // Mendapatkan notifikasi user saat ini
  static Future<List<NotificationModel>> getUserNotifications() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('timestamp', ascending: false);

      final List<dynamic> data = response;
      return data
          .map(
            (json) => NotificationModel.fromMap(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mendapatkan jumlah notifikasi yang belum dibaca
  static Future<int> getUnreadCount() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .eq('is_read', false);

      final List<dynamic> data = response;
      return data.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Menambahkan notifikasi baru
  static Future<NotificationModel?> addNotification({
    required String title,
    required String message,
    required String type,
    String? bookingId,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final notificationId = const Uuid().v4();
      final notification = NotificationModel(
        id: notificationId,
        userId: user.id,
        title: title,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        bookingId: bookingId,
      );

      await SupabaseService.client
          .from('notifications')
          .insert(notification.toMap());

      // Broadcast notification to any listening widgets
      _notificationController.add(notification);

      return notification;
    } catch (e) {
      print('Error adding notification: $e');
      return null;
    }
  }

  // Menandai notifikasi sebagai sudah dibaca
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Menandai semua notifikasi user sebagai sudah dibaca
  static Future<bool> markAllAsRead() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id);

      return true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Notifikasi untuk pembayaran berhasil
  static Future<NotificationModel?> addPaymentSuccessNotification(
    String venueName,
    String bookingDate,
    String timeSlot,
    String bookingId,
  ) async {
    return addNotification(
      title: 'Pembayaran Berhasil',
      message:
          'Pembayaran untuk $venueName pada $bookingDate ($timeSlot) telah berhasil.',
      type: 'payment',
      bookingId: bookingId,
    );
  }

  // Notifikasi untuk pembatalan booking
  static Future<NotificationModel?> addBookingCancelledNotification(
    String venueName,
    String bookingDate,
    String timeSlot,
    String bookingId,
  ) async {
    return addNotification(
      title: 'Booking Dibatalkan',
      message:
          'Booking Anda untuk $venueName pada $bookingDate ($timeSlot) telah dibatalkan.',
      type: 'cancellation',
      bookingId: bookingId,
    );
  }
}
