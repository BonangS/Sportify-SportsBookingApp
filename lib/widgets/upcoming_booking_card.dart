import 'package:flutter/material.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/models/booking_model.dart';
import 'package:intl/intl.dart';

class UpcomingBookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;

  const UpcomingBookingCard({Key? key, required this.booking, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date
    final dateFormatter = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final formattedDate = dateFormatter.format(booking.bookingDate);

    // Venue info
    final venueName = booking.venue?['name'] as String? ?? 'Unknown Venue';
    final venueImageUrl = booking.venue?['image_url'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child:
                      venueImageUrl != null
                          ? Image.network(
                            venueImageUrl,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, _, __) => Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: Colors.grey.shade300,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                          : Container(
                            height: 120,
                            width: double.infinity,
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                ),

                // Status badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Upcoming',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue Name
                  Text(
                    venueName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.startTime} - ${booking.endTime}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
