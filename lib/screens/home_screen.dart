import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:sport_application/models/booking_model.dart';
import 'package:sport_application/models/notification_model.dart';
import 'package:sport_application/models/promo_model.dart';
import 'package:sport_application/models/sport_tip_model.dart';
import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/services/auth_service.dart';
import 'package:sport_application/services/booking_service.dart';
import 'package:sport_application/services/content_service.dart';
import 'package:sport_application/services/notification_service.dart';
import 'package:sport_application/services/venue_service.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/widgets/event_card.dart';
import 'package:sport_application/widgets/mini_map_widget.dart';
import 'package:sport_application/widgets/promo_card.dart';
import 'package:sport_application/widgets/sport_tip_card.dart';
import 'package:sport_application/widgets/upcoming_booking_card.dart';
import 'package:sport_application/widgets/venue_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  List<Venue> venues = [];
  List<Map<String, dynamic>> sportsCategories = [];
  List<PromoModel> promos = [];
  List<SportTipModel> sportTips = [];
  List<BookingModel> upcomingBookings = [];
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> nearbyLocations = [];
  bool isLoading = true;
  String? userName;
  int unreadNotificationsCount = 0;
  List<NotificationModel> notifications = [];
  StreamSubscription? _notificationSubscription;
  final searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadData();
    loadNotifications();

    // Listen for new notifications
    _notificationSubscription = NotificationService.notificationStream.listen((
      _,
    ) {
      loadNotifications();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      setState(() => isLoading = true);

      // Get user profile
      final userProfile = await AuthService.getCurrentUser();

      // Get venues based on category
      final venueList = await VenueService.getVenues(
        category: selectedCategory,
      );

      // Get categories
      final categories = ContentService.getSportsCategories();

      // Get promos
      final promosList = await ContentService.getPromos();

      // Get sport tips
      final tipsList = await ContentService.getSportsTips(
        category: selectedCategory,
      );

      // Get upcoming bookings
      final bookingsList = await BookingService.getUpcomingBookings();

      // Get events
      final eventsList = await ContentService.getUpcomingEvents();

      // Get nearby venues for mini map
      final locations = await ContentService.getNearbyVenueLocations();

      if (mounted) {
        setState(() {
          userName = userProfile?.fullName ?? 'User';
          venues = venueList;
          sportsCategories = categories;
          promos = promosList;
          sportTips = tipsList;
          upcomingBookings = bookingsList;
          events = eventsList;
          nearbyLocations = locations;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> loadNotifications() async {
    try {
      // Get user notifications
      final notificationsList =
          await NotificationService.getUserNotifications();

      // Get unread count
      final unreadCount = await NotificationService.getUnreadCount();

      if (mounted) {
        setState(() {
          notifications = notificationsList;
          unreadNotificationsCount = unreadCount;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  void filterByCategory(String category) {
    setState(() {
      // Toggle category filter (pilih atau hapus pilihan)
      selectedCategory = category == selectedCategory ? null : category;
    });
    // Load data dengan category yang sudah diupdate
    loadData();
  }

  // Show notifications dialog
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            await NotificationService.markAllAsRead();
                            Navigator.pop(context);
                            loadNotifications();
                          },
                          child: const Text('Tandai Semua Dibaca'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child:
                      notifications.isEmpty
                          ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.notifications_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Tidak ada notifikasi',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                          : ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: notifications.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notification = notifications[index];

                              // Choose icon based on notification type
                              IconData icon;
                              Color iconColor;

                              switch (notification.type) {
                                case 'payment':
                                  icon = Icons.payment;
                                  iconColor = Colors.green;
                                  break;
                                case 'cancellation':
                                  icon = Icons.cancel;
                                  iconColor = Colors.red;
                                  break;
                                default:
                                  icon = Icons.notifications;
                                  iconColor = AppColors.primary;
                              }

                              return InkWell(
                                onTap: () async {
                                  // Mark as read when tapped
                                  if (!notification.isRead) {
                                    await NotificationService.markAsRead(
                                      notification.id,
                                    );
                                    loadNotifications();
                                  }

                                  // Navigate to relevant screen based on notification type
                                  if (notification.bookingId != null) {
                                    Navigator.of(context).pop(); // Close dialog
                                    // Navigate to Orders tab with the booking ID
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/main',
                                      (route) => false,
                                      arguments: {
                                        'initialTab': 1,
                                        'bookingId': notification.bookingId,
                                      },
                                    );
                                  }
                                },
                                child: Container(
                                  color:
                                      notification.isRead
                                          ? null
                                          : AppColors.primary.withOpacity(0.05),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: iconColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          icon,
                                          color: iconColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification.title,
                                              style: TextStyle(
                                                fontWeight:
                                                    notification.isRead
                                                        ? FontWeight.normal
                                                        : FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notification.message,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notification.getRelativeTime(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
                const Divider(height: 0),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
    );
  }

  // Show detail promo dialog
  void _showPromoDetailDialog(BuildContext context, PromoModel promo) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    promo.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, _, __) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promo.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        promo.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            promo.validityText,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  promo.validUntil
                                              .difference(DateTime.now())
                                              .inDays <
                                          2
                                      ? Colors.red
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kode Promo:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              promo.code,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                // Implementasi copy ke clipboard
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kode promo disalin!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.copy,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to Venues list
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/main',
                            (route) => false,
                            arguments: {'initialTab': 0},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Gunakan Sekarang'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Show sport tip detail dialog
  void _showSportTipDetailDialog(BuildContext context, SportTipModel tip) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    tip.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, _, __) => Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tip.category,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tip.content,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to Venues list with the specific category
                          filterByCategory(tip.category);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cari Lapangan'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Show the full map
  void _showFullMapDialog(BuildContext context) {
    // Implementasi di aplikasi sebenarnya akan menggunakan peta yang lebih besar
    // atau halaman terpisah
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: const Text('Venue Map')),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MiniMapWidget(
                  locations: nearbyLocations,
                  // User location (untuk demo saja, idealnya dengan geolocation)
                  latitude: -7.2816,
                  longitude: 112.7820,
                ),
              ),
            ),
      ),
    );
  }

  // Section widget builders
  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Promo Spesial'),
        const SizedBox(height: 16),
        SizedBox(
          height:
              260, // Menambah tinggi dari 210 ke 260 untuk menampung konten card
          child:
              promos.isEmpty
                  ? const Center(
                    child: Text(
                      'Tidak ada promo tersedia',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: promos.length,
                    padding: const EdgeInsets.only(left: 16),
                    itemBuilder: (context, index) {
                      return PromoCard(
                        promo: promos[index],
                        onTap:
                            () =>
                                _showPromoDetailDialog(context, promos[index]),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Booking Mendatang',
          onViewAll: () {
            // Navigate to Orders tab
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/main',
              (route) => false,
              arguments: {'initialTab': 1},
            );
          },
        ),
        const SizedBox(height: 16),
        upcomingBookings.isEmpty
            ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak ada booking mendatang',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to Explore tab
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/main',
                            (route) => false,
                            arguments: {'initialTab': 0},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Booking Sekarang'),
                      ),
                    ],
                  ),
                ),
              ),
            )
            : SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: upcomingBookings.length,
                padding: const EdgeInsets.only(left: 16),
                itemBuilder: (context, index) {
                  return UpcomingBookingCard(
                    booking: upcomingBookings[index],
                    onTap: () {
                      // Navigate to Orders tab with the booking ID
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/main',
                        (route) => false,
                        arguments: {
                          'initialTab': 1,
                          'bookingId': upcomingBookings[index].id,
                        },
                      );
                    },
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _buildSportTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Tips Olahraga'),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child:
              sportTips.isEmpty
                  ? const Center(
                    child: Text(
                      'Tidak ada tips tersedia',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sportTips.length,
                    padding: const EdgeInsets.only(left: 16),
                    itemBuilder: (context, index) {
                      return SportTipCard(
                        sportTip: sportTips[index],
                        onTap:
                            () => _showSportTipDetailDialog(
                              context,
                              sportTips[index],
                            ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEventsSection() {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Event Olahraga Terdekat'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children:
                events.map((event) {
                  return EventCard(
                    event: event,
                    onTap: () async {
                      // In a real app, navigate to event detail page
                      // For this demo, just show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Event: ${event['title']}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Venue Di Sekitar Anda'),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: MiniMapWidget(
            locations: nearbyLocations,
            // User location (untuk demo saja, idealnya dengan geolocation)
            latitude: -7.2816,
            longitude: 112.7820,
            onViewFullMap: () => _showFullMapDialog(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan image_url dari data venues yang sudah diambil dari database
    final List<String> promoImages =
        venues
            .where(
              (venue) => venue.imageUrl != null && venue.imageUrl!.isNotEmpty,
            )
            .map((venue) => venue.imageUrl!)
            .toList();

    return Scaffold(
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${userName}!',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const Text(
                                  'Ayo olahraga hari ini!',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _showNotificationsDialog(context);
                                  },
                                  icon: const Icon(
                                    Icons.notifications_none,
                                    size: 28,
                                  ),
                                ),
                                if (unreadNotificationsCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          unreadNotificationsCount > 9
                                              ? '9+'
                                              : unreadNotificationsCount
                                                  .toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              isSearching = value.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari lapangan futsal, badminton...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            suffixIcon:
                                isSearching
                                    ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          searchController.clear();
                                          isSearching = false;
                                        });
                                      },
                                    )
                                    : null,
                            filled: true,
                            fillColor: AppColors.backgroundGrey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              // Navigate to search results
                              // In a real app, this would search venues
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Mencari: $value'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 24), // Kategori
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: sportsCategories.length,
                          padding: const EdgeInsets.only(left: 16),
                          itemBuilder: (context, index) {
                            final category = sportsCategories[index]['label'];
                            final isSelected = category == selectedCategory;

                            return GestureDetector(
                              onTap: () => filterByCategory(category),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : AppColors.availableSlot,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        sportsCategories[index]['icon'],
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : AppColors.primary,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      sportsCategories[index]['label'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ===== URUTAN WIDGET DIPERBAIKI DI SINI =====

                      // Sports tips section
                      _buildSportTipsSection(),
                      const SizedBox(height: 24),

                      // Events section
                      _buildEventsSection(),
                      const SizedBox(height: 24),

                      // Promo Banner
                      promoImages.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada venue tersedia',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : SizedBox(
                            height: 150,
                            child: CarouselSlider.builder(
                              unlimitedMode: promoImages.length > 1,
                              autoSliderTransitionTime: const Duration(
                                milliseconds: 500,
                              ),
                              enableAutoSlider: promoImages.length > 1,
                              slideBuilder: (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      promoImages[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.grey.shade200,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Gambar tidak tersedia',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              slideTransform: const CubeTransform(),
                              itemCount: promoImages.length,
                            ),
                          ),
                      const SizedBox(height: 24),

                      // Upcoming bookings section
                      _buildUpcomingBookingsSection(),
                      const SizedBox(height: 24),

                      // Promos section (detailed)
                      _buildPromosSection(),
                      const SizedBox(height: 24),

                      // Rekomendasi Terdekat
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Rekomendasi Terdekat'),
                          const SizedBox(height: 16),
                          venues.isEmpty
                              ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text(
                                    'Tidak ada venue yang tersedia',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                              : SizedBox(
                                height: 270,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: venues.length,
                                  padding: const EdgeInsets.only(left: 16),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                        right: 16.0,
                                      ),
                                      child: VenueCard(venue: venues[index]),
                                    );
                                  },
                                ),
                              ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Map section
                      _buildNearbyMapSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
      ),
    );
  }
}
