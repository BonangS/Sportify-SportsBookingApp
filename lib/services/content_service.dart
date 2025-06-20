import 'package:flutter/material.dart';
import 'package:sport_application/models/promo_model.dart';
import 'package:sport_application/models/sport_tip_model.dart';
import 'package:sport_application/models/venue_model.dart';

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
    // Dalam aplikasi yang sebenarnya, ini akan mengambil data dari API/database
    // Untuk demo, saya gunakan data statis
    final promos = [
      {
        'id': '1',
        'title': 'Diskon 20% Booking Futsal',
        'imageUrl':
            'https://megahgemilang.com/wp-content/uploads/2020/11/Tips-Cara-Membuat-Lapangan-Futsal.jpg',
        'description':
            'Booking lapangan futsal sekarang dan dapatkan diskon 20%',
        'validUntil': DateTime.now().add(const Duration(days: 7)),
        'code': 'FUTSAL20',
      },
      {
        'id': '2',
        'title': 'Promo Badminton Weekend',
        'imageUrl':
            'https://asset.ayo.co.id/image/venue/168888208726905.image_cropper_1688882076172_large.jpg',
        'description':
            'Dapatkan cashback 10% untuk booking lapangan badminton di akhir pekan',
        'validUntil': DateTime.now().add(const Duration(days: 14)),
        'code': 'WEEKEND10',
      },
      {
        'id': '3',
        'title': 'Special Promo Basket',
        'imageUrl':
            'https://akcdn.detik.net.id/visual/2023/02/22/ilustrasi-lapangan-basket_169.jpeg?w=1200',
        'description': 'Booking 2 jam, gratis 30 menit untuk lapangan basket',
        'validUntil': DateTime.now().add(const Duration(days: 30)),
        'code': 'BASKET30',
      },
      {
        'id': '4',
        'title': 'Promo Padel Tennis',
        'imageUrl':
            'https://cdn.britannica.com/09/143709-050-85350FBE/ball-tennis-court.jpg',
        'description':
            'Booking lapangan Padel Tennis di hari Selasa dan dapatkan diskon 15%',
        'validUntil': DateTime.now().add(const Duration(days: 21)),
        'code': 'PADEL15',
      },
      {
        'id': '5',
        'title': 'Tennis Court Special',
        'imageUrl':
            'https://static.nike.com/a/images/f_auto,cs_srgb/w_1536,c_limit/f9j4tqqi5zydaklxjy1i/nike-tennis-camps.jpg',
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
    // Dalam aplikasi yang sebenarnya, ini akan mengambil data dari API/database
    // Untuk demo, saya gunakan data statis
    final allTips = [
      {
        'id': '1',
        'category': 'Futsal',
        'title': 'Tips Meningkatkan Skill Dribbling',
        'imageUrl':
            'https://cdn0-production-images-kly.akamaized.net/gSYMZkfdPVEiRsOpgaaJ8KWs-Rc=/800x450/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/3934229/original/024516100_1644481507-pexels-pixabay-47730.jpg',
        'content':
            'Latihan dribbling secara rutin dengan fokus pada kontrol bola dan kecepatan.',
      },
      {
        'id': '2',
        'category': 'Badminton',
        'title': 'Cara Meningkatkan Smash',
        'imageUrl':
            'https://blog-images-1.pharmeasy.in/blog/production/wp-content/uploads/2021/01/30152758/shutterstock_149662307-1.jpg',
        'content':
            'Tingkatkan kekuatan lengan dan koordinasi untuk smash yang lebih mematikan.',
      },
      {
        'id': '3',
        'category': 'Basket',
        'title': 'Teknik Free Throw Sempurna',
        'imageUrl':
            'https://img.olympics.com/images/image/private/t_s_pog_staticContent_hero_lg_2x/f_auto/primary/ufyaafuzmkaudonrjike',
        'content':
            'Fokus pada posisi kaki dan konsistensi gerakan saat melakukan free throw.',
      },
      {
        'id': '4',
        'category': 'Voli',
        'title': 'Tips Receive dan Passing',
        'imageUrl':
            'https://img.olympics.com/images/image/private/t_s_pog_staticContent_hero_lg_2x/f_auto/primary/vjg2s9j6xayqwb61wzkt',
        'content':
            'Posisi tubuh yang tepat saat menerima bola sangat penting dalam permainan voli.',
      },
      {
        'id': '5',
        'category': 'Pemanasan',
        'title': 'Pemanasan yang Tepat Sebelum Olahraga',
        'imageUrl':
            'https://cdn1-production-images-kly.akamaized.net/oCm7nJUFwY11chiUW4WImIRi3L0=/800x450/smart/filters:quality(75):strip_icc():format(webp)/kly-media-production/medias/2754932/original/029823800_1552971555-iStock-890042784.jpg',
        'content':
            'Lakukan pemanasan selama 10-15 menit untuk menghindari cedera.',
      },
      {
        'id': '6',
        'category': 'Nutrisi',
        'title': 'Makanan yang Sebaiknya Dikonsumsi Sebelum Olahraga',
        'imageUrl':
            'https://asset.kompas.com/crops/9FagFiwhNR0GFBDRnT_m5qr7HwY=/0x0:1000x667/750x500/data/photo/2020/07/22/5f17b861cd283.jpg',
        'content':
            'Konsumsi karbohidrat kompleks dan protein 2-3 jam sebelum olahraga.',
      },
      {
        'id': '7',
        'category': 'Padel',
        'title': 'Teknik Dasar Padel Tennis',
        'imageUrl':
            'https://letsplaypadel.ca/static/3f0389b2aa3ea007b9dd1bdb8daffe65/14be6/shutterstock-1934013679.jpg',
        'content':
            'Pelajari grip yang tepat dan teknik pukulan dasar untuk bermain padel tennis.',
      },
      {
        'id': '8',
        'category': 'Tenis',
        'title': 'Meningkatkan Serve dalam Tennis',
        'imageUrl':
            'https://www.perfect-tennis.com/wp-content/uploads/2019/07/tennis-serve-toss.jpg',
        'content':
            'Kunci serve yang baik adalah konsistensi toss dan timing pukulan yang tepat.',
      },
      {
        'id': '9',
        'category': 'Cricket',
        'title': 'Teknik Batting dalam Cricket',
        'imageUrl':
            'https://cdn.dnaindia.com/sites/default/files/styles/full/public/2021/01/20/951102-virat-kohli-2.jpg',
        'content':
            'Posisi badan dan teknik ayunan yang tepat untuk batting dalam cricket.',
      },
      {
        'id': '10',
        'category': 'Golf',
        'title': 'Tips Putting yang Akurat',
        'imageUrl':
            'https://golf.com/wp-content/uploads/2020/04/putting-drill-2.jpg',
        'content':
            'Fokus pada konsistensi ayunan dan kontrol kecepatan untuk pukulan putting.',
      },
    ];

    // Filter berdasarkan category jika ada
    final tips =
        category != null
            ? allTips.where((tip) => tip['category'] == category).toList()
            : allTips;

    return tips.map((tip) => SportTipModel.fromJson(tip)).toList();
  }

  // Method untuk mendapatkan event olahraga
  static Future<List<Map<String, dynamic>>> getUpcomingEvents() async {
    // Untuk implementasi demo
    return [
      {
        'id': '1',
        'title': 'Turnamen Futsal Antar Kampus',
        'date': DateTime.now().add(const Duration(days: 5)),
        'location': 'GOR Futsal Center',
        'imageUrl':
            'https://s3.ivideosmart.com/production/document/100423/TQkvWwGdrU3lBQUQ6IB3/thumbnails/TQkvWwGdrU3lBQUQ6IB3_1509450657.0_640_360.jpg',
      },
      {
        'id': '2',
        'title': 'Workshop Teknik Badminton',
        'date': DateTime.now().add(const Duration(days: 3)),
        'location': 'Badminton Hall',
        'imageUrl':
            'https://www.yonex.com/media/wysiwyg/yonex-badminton-doubles-roundup-banner.jpg',
      },
      {
        'id': '3',
        'title': 'Kompetisi Basket 3x3',
        'date': DateTime.now().add(const Duration(days: 7)),
        'location': 'Lapangan Basket Central',
        'imageUrl':
            'https://assets.nst.com.my/images/articles/25bb1_1545694912.jpg',
      },
      {
        'id': '4',
        'title': 'Open Tournament Tennis',
        'date': DateTime.now().add(const Duration(days: 14)),
        'location': 'Tennis Court Plaza',
        'imageUrl':
            'https://www.atptour.com/-/media/images/news/2022/01/04/00/45/nadal-melbourne-2022-first-round.jpg',
      },
    ];
  }

  // Method untuk mendapatkan lokasi venue terdekat (untuk fitur mini map)
  static Future<List<Map<String, dynamic>>> getNearbyVenueLocations() async {
    // Dalam aplikasi yang sebenarnya, ini akan mengambil data lokasi dari GPS dan database
    // Untuk demo, saya gunakan data statis
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
