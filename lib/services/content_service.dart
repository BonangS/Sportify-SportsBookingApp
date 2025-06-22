import 'package:flutter/material.dart';
import 'package:Sportify/models/promo_model.dart';
import 'package:Sportify/models/sport_tip_model.dart';
import 'package:Sportify/models/venue_model.dart';

class ContentService {
  // Method untuk mendapatkan daftar kategori olahraga
  static List<Map<String, dynamic>> getSportsCategories() {
    return [
      {'icon': Icons.sports_soccer, 'label': 'Futsal'},
      {'icon': Icons.sports_tennis, 'label': 'Badminton'},
      {'icon': Icons.sports_basketball, 'label': 'Basket'},
      {'icon': Icons.sports_volleyball, 'label': 'Voli'},
      {'icon': Icons.sports_tennis, 'label': 'Padel'},
      {'icon': Icons.sports_tennis, 'label': 'Tenis'},
      {'icon': Icons.sports_cricket, 'label': 'Cricket'},
      {'icon': Icons.sports_golf, 'label': 'Golf'},
      {'icon': Icons.sports_hockey, 'label': 'Hockey'},
      {'icon': Icons.sports_rugby, 'label': 'Rugby'},
    ];
  }

  // Method untuk mendapatkan promo
  static Future<List<PromoModel>> getPromos() async {
    // Data statis dengan URL gambar yang stabil
    final promos = [
      {
        'id': '1',
        'title': 'Promo 100k 2 jam Futsal',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSX7J2DmBa2MCECZviA4pF6lSOLBvfqZDAORw&s',
        'description':
            'Booking lapangan futsal sekarang dan dapatkan diskon 20%',
        'validUntil': DateTime.now().add(const Duration(days: 7)),
        'code': 'FUTSAL20',
      },
      {
        'id': '2',
        'title': 'Promo Badminton Weekend',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT5JFLSNji0t24n104AmLIjadlwajaUymdFxw&s',
        'description':
            'Dapatkan cashback 10% untuk booking lapangan badminton di akhir pekan',
        'validUntil': DateTime.now().add(const Duration(days: 14)),
        'code': 'WEEKEND10',
      },
      {
        'id': '3',
        'title': 'Special Promo Basket',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSCHzTJNC73KILqs7-QJPqXYJwxqrEvJSsAOw&s',
        'description': 'Booking 2 jam, gratis 30 menit untuk lapangan basket',
        'validUntil': DateTime.now().add(const Duration(days: 30)),
        'code': 'BASKET30',
      },
      {
        'id': '4',
        'title': 'Promo Padel Tennis',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQpvgYr6iCFdjMTso1fSFl-TFS9ELJvSywqmw&s',
        'description':
            'Booking lapangan Padel Tennis di hari Selasa dan dapatkan diskon 30%',
        'validUntil': DateTime.now().add(const Duration(days: 21)),
        'code': 'PADEL15',
      },
      {
        'id': '5',
        'title': 'Tennis Court Special',
        'imageUrl':
            'https://images.pexels.com/photos/1432034/pexels-photo-1432034.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        'description':
            'Ajak teman, dapat diskon. Booking untuk 4 orang dan dapatkan diskon 25%',
        'validUntil': DateTime.now().add(const Duration(days: 10)),
        'code': 'TENNIS25',
      },
    ];

    return promos.map((promo) => PromoModel.fromJson(promo)).toList();
  }

  // Method untuk mendapatkan tips olahraga
  static Future<List<SportTipModel>> getSportsTips({String? category}) async {
    // Data statis dengan URL gambar yang stabil
    final allTips = [
      {
        'id': '1',
        'category': 'Futsal',
        'title': 'Tips Meningkatkan Skill Dribbling',
        'imageUrl':
            'https://asset.kompas.com/crops/C25bZR5i5GmYq1k8sPVDFkvZ34E=/0x0:932x621/1200x800/data/photo/2021/09/24/614dc2ae58a28.png',
        'content':
            'Latih kontrol bola dengan melakukan dribbling menggunakan kedua kaki. Mulai dengan kecepatan rendah dan tingkatkan secara bertahap.',
      },
      {
        'id': '2',
        'category': 'Badminton',
        'title': 'Cara Meningkatkan Smash',
        'imageUrl':
            'https://vendors.id/wp-content/uploads/2024/02/ezgif-6-c51d735a49.webp',
        'content':
            'Tingkatkan kekuatan lengan dan koordinasi untuk smash yang lebih mematikan. Lakukan latihan push-up dan pull-up secara rutin untuk meningkatkan kekuatan lengan.',
      },
      {
        'id': '3',
        'category': 'Basket',
        'title': 'Teknik Free Throw Sempurna',
        'imageUrl':
            'https://www.dbl.id/thumbs/extra-large/uploads/post/2020/05/25/LeBron_James_-_USA_Today.jpg',
        'content':
            'Fokus pada posisi kaki dan konsistensi gerakan saat melakukan free throw. Pastikan lutut ditekuk dan follow-through yang sempurna.',
      },
      {
        'id': '4',
        'category': 'Voli',
        'title': 'Tips Receive dan Passing',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT7Q06_MjymyIWSY_IMtpTFo95MmmwWoD-Xzw&s',
        'content':
            'Posisi tubuh yang tepat saat menerima bola sangat penting dalam permainan voli. Tekuk lutut dan siapkan tangan dalam posisi yang benar.',
      },
      {
        'id': '5',
        'category': 'Pemanasan',
        'title': 'Pemanasan yang Tepat Sebelum Olahraga',
        'imageUrl':
            'https://smpsepuluhnopember.sch.id/storage/posts/posts_cr8r.jpg',
        'content':
            'Lakukan pemanasan selama 10-15 menit untuk menghindari cedera. Mulai dari peregangan ringan hingga gerakan yang lebih dinamis.',
      },
      {
        'id': '6',
        'category': 'Nutrisi',
        'title': 'Makanan yang Sebaiknya Dikonsumsi Sebelum Olahraga',
        'imageUrl': 'https://blog.nasm.org/hubfs/sports-nutrition-guide.jpg',
        'content':
            'Konsumsi karbohidrat kompleks dan protein 2-3 jam sebelum olahraga. Hindari makanan berlemak dan terlalu berat.',
      },
      {
        'id': '7',
        'category': 'Padel',
        'title': 'Teknik Dasar Padel Tennis',
        'imageUrl':
            'https://static.promediateknologi.id/crop/0x0:0x0/0x0/webp/photo/p2/01/2025/01/04/padel-3780755599.jpg',
        'content':
            'Pelajari grip yang tepat dan teknik pukulan dasar untuk bermain padel tennis. Fokus pada kontrol dan akurasi.',
      },
      {
        'id': '8',
        'category': 'Tenis',
        'title': 'Meningkatkan Serve dalam Tennis',
        'imageUrl':
            'https://specials-images.forbesimg.com/imageserve/66c5f97ef4735ff16457f99c/Coco-Gauff/1440x0.jpg?fit=scale',
        'content':
            'Kunci serve yang baik adalah konsistensi toss dan timing pukulan yang tepat. Latih serve secara rutin untuk meningkatkan akurasi.',
      },
      {
        'id': '9',
        'category': 'Cricket',
        'title': 'Teknik Batting dalam Cricket',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGnQgH_D0ZNGagg7dGnoFJwN1ts3LTFzExLw&s',
        'content':
            'Pelajari teknik batting dasar cricket dengan fokus pada footwork dan timing yang tepat.',
      },
    ];

    final tips =
        category != null
            ? allTips.where((tip) => tip['category'] == category).toList()
            : allTips;

    return tips.map((tip) => SportTipModel.fromJson(tip)).toList();
  }

  // Method untuk mendapatkan event olahraga
  static Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    // Data statis dengan URL gambar yang stabil
    return [
      {
        'id': '1',
        'title': 'Turnamen Futsal Antar Kampus',
        'date': DateTime.now().add(const Duration(days: 5)),
        'location': 'GOR Futsal Center',
        'imageUrl':
            'https://fsh.walisongo.ac.id/wp-content/uploads/2023/07/WhatsApp%20Image%202023-07-10%20at%2008.20.55.jpeg',
        'description':
            'Turnamen futsal tahunan antar universitas dengan total hadiah jutaan rupiah. Daftarkan tim Anda sekarang!',
      },
      {
        'id': '2',
        'title': 'Workshop Teknik Badminton',
        'date': DateTime.now().add(const Duration(days: 3)),
        'location': 'Badminton Hall',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsyhimS825jff5u6diMj9fO1y5ZHXphORvxg&s',
        'description':
            'Pelajari teknik dasar dan lanjutan badminton dari pelatih nasional. Tersedia sesi untuk pemula dan tingkat lanjut.',
      },
      {
        'id': '3',
        'title': 'Kompetisi Basket 3x3',
        'date': DateTime.now().add(const Duration(days: 7)),
        'location': 'Lapangan Basket Central',
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZIa2o6-wvj07BDSajTI2U9zMCfp90vOzthg&s',
        'description':
            'Kompetisi basket 3x3 untuk semua kategori umur. Daftar segera karena kuota terbatas!',
      },
      {
        'id': '4',
        'title': 'Open Tournament Tennis',
        'date': DateTime.now().add(const Duration(days: 14)),
        'location': 'Tennis Court Plaza',
        'imageUrl':
            'https://d1csarkz8obe9u.cloudfront.net/posterpreviews/tennis-tournament-flyer-template-design-870648063a74dc7ece9f2fc39d93ffc2_screen.jpg?ts=1689962421',
        'description':
            'Turnamen tennis terbuka untuk kategori tunggal dan ganda. Pendaftaran dibuka sampai 3 hari sebelum acara.',
      },
    ];
  }

  // Method untuk mendapatkan lokasi venue terdekat (untuk fitur mini map)
  static Future<List<Map<String, dynamic>>> getNearbyVenueLocations() async {
    // Data statis
    return [
      {
        'id': '1',
        'name': 'Futsal Center',
        'latitude': -7.2806,
        'longitude': 112.7803,
        'category': 'Futsal',
      },
      {
        'id': '2',
        'name': 'Badminton Hall',
        'latitude': -7.2826,
        'longitude': 112.7753,
        'category': 'Badminton',
      },
      {
        'id': '3',
        'name': 'Basketball Arena',
        'latitude': -7.2756,
        'longitude': 112.7863,
        'category': 'Basket',
      },
      {
        'id': '4',
        'name': 'Volleyball Court',
        'latitude': -7.2836,
        'longitude': 112.7823,
        'category': 'Voli',
      },
      {
        'id': '5',
        'name': 'Padel Center',
        'latitude': -7.2846,
        'longitude': 112.7843,
        'category': 'Padel',
      },
      {
        'id': '6',
        'name': 'Tennis Club',
        'latitude': -7.2816,
        'longitude': 112.7783,
        'category': 'Tenis',
      },
      {
        'id': '7',
        'name': 'Cricket Ground',
        'latitude': -7.2876,
        'longitude': 112.7853,
        'category': 'Cricket',
      },
    ];
  }
}
