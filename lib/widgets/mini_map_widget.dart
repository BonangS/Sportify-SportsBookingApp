import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:Sportify/utils/app_colors.dart';

class MiniMapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final double? latitude;
  final double? longitude;
  final VoidCallback? onViewFullMap;

  const MiniMapWidget({
    Key? key,
    required this.locations,
    this.latitude,
    this.longitude,
    this.onViewFullMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Center position (default to first location or use provided coordinates)
    final centerLat = latitude ?? locations.first['latitude'];
    final centerLng = longitude ?? locations.first['longitude'];
    final center = LatLng(centerLat, centerLng);

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    // User location marker if available
                    if (latitude != null && longitude != null)
                      Marker(
                        point: center,
                        width: 80,
                        height: 80,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_pin_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'You',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Location markers
                    ...locations.map((location) {
                      final venueLocation = LatLng(
                        location['latitude'],
                        location['longitude'],
                      );
                      final category = location['category'] as String;

                      // Choose icon based on category
                      IconData icon;
                      switch (category) {
                        case 'Futsal':
                          icon = Icons.sports_soccer;
                          break;
                        case 'Badminton':
                        case 'Padel':
                        case 'Tenis':
                          icon = Icons.sports_tennis;
                          break;
                        case 'Basket':
                          icon = Icons.sports_basketball;
                          break;
                        case 'Voli':
                          icon = Icons.sports_volleyball;
                          break;
                        case 'Cricket':
                          icon = Icons.sports_cricket;
                          break;
                        case 'Golf':
                          icon = Icons.sports_golf;
                          break;
                        default:
                          icon = Icons.location_on;
                      }

                      return Marker(
                        point: venueLocation,
                        width: 100,
                        height: 100,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(icon, color: Colors.white, size: 16),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                location['name'] as String,
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),

            // View full map button
            Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: onViewFullMap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.fullscreen,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Perbesar',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
