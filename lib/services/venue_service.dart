import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/services/supabase_service.dart';

class VenueService {
  static Future<List<Venue>> getVenues({String? category}) async {
    try {
      var query = SupabaseService.client.from('venues').select('*');

      // Filter berdasarkan kategori jika dipilih
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      final response = await query;

      List<Venue> venuesList = [];
      for (var venueData in response) {
        // Ambil data fasilitas dari tabel venue_facilities
        final facilitiesResponse = await SupabaseService.client
            .from('venue_facilities')
            .select('facilities:facility_id(name)')
            .eq('venue_id', venueData['id']);

        List<String> facilities = [];
        if (facilitiesResponse != null) {
          for (var facility in facilitiesResponse) {
            if (facility['facilities'] != null &&
                facility['facilities']['name'] != null) {
              facilities.add(facility['facilities']['name']);
            }
          }
        }

        // Tambahkan fasilitas ke venue data
        venueData['facilities'] = facilities;

        venuesList.add(Venue.fromJson(venueData));
      }

      return venuesList;
    } catch (e) {
      print('Error fetching venues: $e');
      return [];
    }
  }

  static Future<Venue?> getVenueById(String id) async {
    try {
      final response =
          await SupabaseService.client
              .from('venues')
              .select('*')
              .eq('id', id)
              .single();

      // Ambil data fasilitas
      final facilitiesResponse = await SupabaseService.client
          .from('venue_facilities')
          .select('facilities:facility_id(name)')
          .eq('venue_id', id);

      List<String> facilities = [];
      if (facilitiesResponse != null) {
        for (var facility in facilitiesResponse) {
          if (facility['facilities'] != null &&
              facility['facilities']['name'] != null) {
            facilities.add(facility['facilities']['name']);
          }
        }
      }

      response['facilities'] = facilities;

      return Venue.fromJson(response);
    } catch (e) {
      print('Error fetching venue details: $e');
      return null;
    }
  }

  static Future<List<String>> getFacilities() async {
    try {
      final response = await SupabaseService.client
          .from('facilities')
          .select('name')
          .order('name', ascending: true);

      return List<String>.from(response.map((facility) => facility['name']));
    } catch (e) {
      print('Error fetching facilities: $e');
      return [];
    }
  }
}
