import 'package:flutter/material.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:sport_application/utils/image_utils.dart';

class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback? onTap;

  const EventCard({Key? key, required this.event, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = event['date'] as DateTime;
    final formattedDate = DateFormat('dd MMM yyyy', 'id_ID').format(date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          children: [
            // Event Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Image.network(
                ImageUtils.getEventImage(
                  event['imageUrl'] as String?,
                  event['title'] as String,
                  event['location'] as String,
                ),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, _, __) => Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),

            // Event Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      event['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Event Date
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

                    // Event Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event['location'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Arrow icon
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
