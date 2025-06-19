import 'package:sport_application/models/venue_model.dart';
import 'package:sport_application/services/supabase_service.dart';

class VenueService {
  static final _venues = SupabaseService.client.from('venues');
  static final _venueFacilities = SupabaseService.client.from('venue_facilities');

  static Future<List<Venue>> getVenues() async {
    try {
      final response = await _venues
          .select('*, facilities!venue_facilities(name)')
          .order('created_at');
      
      return (response as List)
          .map((venue) => Venue.fromJson(venue))
          .toList();
    } catch (e) {
      print('Error fetching venues: $e');
      return [];
    }
  }

  static Future<Venue?> getVenueById(String id) async {
    try {
      final response = await _venues
          .select('*, facilities!venue_facilities(name)')
          .eq('id', id)
          .single();
      
      return Venue.fromJson(response);
    } catch (e) {
      print('Error fetching venue: $e');
      return null;
    }
  }

  static Future<List<Venue>> searchVenues(String query) async {
    try {
      final response = await _venues
          .select('*, facilities!venue_facilities(name)')
          .ilike('name', '%$query%')
          .order('created_at');
      
      return (response as List)
          .map((venue) => Venue.fromJson(venue))
          .toList();
    } catch (e) {
      print('Error searching venues: $e');
      return [];
    }
  }
}
