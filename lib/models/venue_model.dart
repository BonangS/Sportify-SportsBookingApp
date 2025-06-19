class Venue {
  final String id;
  final String name;
  final String address;
  final String? imageUrl;
  final double rating;
  final double? distance;
  final int pricePerHour;
  final List<String> facilities;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Venue({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    this.rating = 0.0,
    this.distance,
    required this.pricePerHour,
    required this.facilities,
    this.createdAt,
    this.updatedAt,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      imageUrl: json['image_url'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: json['distance']?.toDouble(),
      pricePerHour: json['price_per_hour'],
      facilities: List<String>.from(json['facilities'] ?? []),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'image_url': imageUrl,
      'rating': rating,
      'distance': distance,
      'price_per_hour': pricePerHour,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Data Dummy
final List<Venue> dummyVenues = [
  Venue(
    id: '1',
    name: 'Champions Futsal',
    address: 'Jl. Jenderal Sudirman No. 12, Jakarta Selatan',
    imageUrl: 'https://images.unsplash.com/photo-1552318965-6e6be7484ada?q=80&w=2070&auto=format&fit=crop',
    rating: 4.8,
    distance: 1.2,
    pricePerHour: 150000,
    facilities: ['Parkir', 'Mushola', 'Kantin', 'WiFi'],
  ),
  Venue(
    id: '2',
    name: 'Garuda Badminton Hall',
    address: 'Jl. Gatot Subroto No. 88, Jakarta Pusat',
    imageUrl: 'https://images.unsplash.com/photo-1574269939522-31a12628df52?q=80&w=2070&auto=format&fit=crop',
    rating: 4.9,
    distance: 3.5,
    pricePerHour: 85000,
    facilities: ['Parkir', 'Shower', 'Kantin'],
  ),
  Venue(
    id: '3',
    name: 'Galaxy Mini Soccer',
    address: 'Jl. Raya Bogor KM 20, Jakarta Timur',
    imageUrl: 'https://images.unsplash.com/photo-1628891890377-573583a03387?q=80&w=2070&auto=format&fit=crop',
    rating: 4.7,
    distance: 8.1,
    pricePerHour: 250000,
    facilities: ['Parkir Luas', 'Mushola', 'Kantin', 'WiFi', 'Locker'],
  ),
];