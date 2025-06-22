class ImageUtils {
  // Returns appropriate image for events based on title keywords or locationName if imageUrl is empty
  static String getEventImage(
    String? imageUrl,
    String title,
    String locationName,
  ) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return imageUrl;
    }

    // Check title or location for keywords
    final titleLower = title.toLowerCase();
    final locationLower = locationName.toLowerCase();

    if (titleLower.contains('futsal') || locationLower.contains('futsal')) {
      return 'https://img.freepik.com/free-photo/soccer-football-stadium-with-spotlight_158595-2391.jpg';
    } else if (titleLower.contains('badminton') ||
        locationLower.contains('badminton')) {
      return 'https://img.freepik.com/free-photo/badminton-court_1339-4132.jpg';
    } else if (titleLower.contains('basket') ||
        locationLower.contains('basket')) {
      return 'https://img.freepik.com/free-photo/empty-basketball-court_1339-4267.jpg';
    } else if (titleLower.contains('voli') ||
        titleLower.contains('volleyball') ||
        locationLower.contains('voli')) {
      return 'https://img.freepik.com/free-photo/volleyball-sports-hall_1232-3255.jpg';
    } else if (titleLower.contains('padel') ||
        locationLower.contains('padel')) {
      return 'https://img.freepik.com/free-photo/padel-court-with-night-lights_1139-1269.jpg';
    } else if (titleLower.contains('tennis') ||
        titleLower.contains('tenis') ||
        locationLower.contains('tennis')) {
      return 'https://img.freepik.com/free-photo/tennis-court_1232-3496.jpg';
    } else if (titleLower.contains('cricket') ||
        locationLower.contains('cricket')) {
      return 'https://img.freepik.com/free-photo/cricket-stadium-with-night-lights_1339-6241.jpg';
    } else {
      // Default sports event image
      return 'https://img.freepik.com/free-photo/stadium-with-lights-white-banner_1166-1347.jpg';
    }
  }

  // Returns a themed default sports image based on sport name
  static String getDefaultSportImage(String sportName) {
    switch (sportName.toLowerCase()) {
      case 'futsal':
        return 'https://img.freepik.com/free-photo/soccer-players-action-professional-stadium_654080-1232.jpg';
      case 'badminton':
        return 'https://img.freepik.com/free-photo/badminton-concept-with-shuttlecock-racket_23-2149940874.jpg';
      case 'basket':
      case 'basketball':
        return 'https://img.freepik.com/free-photo/basketball-game-action_654080-1542.jpg';
      case 'voli':
      case 'volleyball':
        return 'https://img.freepik.com/free-photo/volleyball-ball-net-beach_23-2148163841.jpg';
      case 'padel':
        return 'https://img.freepik.com/free-photo/tennis-padel-court-field-during-sunny-day_23-2149014156.jpg';
      case 'tenis':
      case 'tennis':
        return 'https://img.freepik.com/free-photo/tennis-court-player_1150-14264.jpg';
      case 'golf':
        return 'https://img.freepik.com/free-photo/golf-ball-tee-golf-course_1150-17956.jpg';
      case 'cricket':
        return 'https://img.freepik.com/free-photo/cricket-equipment-green-grass-field_1150-20577.jpg';
      case 'rugby':
        return 'https://img.freepik.com/free-photo/rugby-feld_1385-730.jpg';
      default:
        return 'https://img.freepik.com/free-photo/sports-tools_53876-138077.jpg';
    }
  }
}
