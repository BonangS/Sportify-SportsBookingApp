import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/utils/app_colors.dart';
import 'package:sport_application/widgets/venue_card.dart';
import 'package:sport_application/services/venue_service.dart';
import 'package:sport_application/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  List<Venue> venues = [];
  bool isLoading = true;
  String? userName;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      setState(() => isLoading = true);
      final userProfile = await AuthService.getCurrentUser();
      final venueList = await VenueService.getVenues(
        category: selectedCategory,
      );

      setState(() {
        userName = userProfile?.fullName ?? 'User';
        venues = venueList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.sports_soccer, 'label': 'Futsal'},
      {'icon': Icons.sports_tennis, 'label': 'Badminton'},
      {'icon': Icons.sports_basketball, 'label': 'Basket'},
      {'icon': Icons.sports_volleyball, 'label': 'Voli'},
    ];
    final List<String> promoImages = [
      'https://megahgemilang.com/wp-content/uploads/2020/11/Tips-Cara-Membuat-Lapangan-Futsal.jpg',
      'https://asset.ayo.co.id/image/venue/168888208726905.image_cropper_1688882076172_large.jpg',
      'https://akcdn.detik.net.id/visual/2023/02/22/ilustrasi-lapangan-basket_169.jpeg?w=1200',
    ];

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
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.notifications_none,
                                    size: 28,
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari lapangan futsal, badminton...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
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
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Kategori
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          padding: const EdgeInsets.only(left: 16),
                          itemBuilder: (context, index) {
                            final category = categories[index]['label'];
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
                                        categories[index]['icon'],
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : AppColors.primary,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      categories[index]['label'],
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

                      // Promo Banner
                      SizedBox(
                        height: 150,
                        child: CarouselSlider.builder(
                          unlimitedMode: true,
                          autoSliderTransitionTime: const Duration(
                            milliseconds: 500,
                          ),
                          enableAutoSlider: true,
                          slideBuilder: (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(promoImages[index]),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            );
                          },
                          slideTransform: const CubeTransform(),
                          itemCount: promoImages.length,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Rekomendasi Terdekat
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Rekomendasi Terdekat',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
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
                      ),
                      const SizedBox(height: 16),

                      // Venue Cards
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
                ),
      ),
    );
  }
}
