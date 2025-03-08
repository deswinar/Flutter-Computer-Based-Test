import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch users with a specific role ('student' in this case)
  Future<List<Map<String, dynamic>>> getUsersByRole(
    String role, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('users') // Assuming you're using a 'users' table
          .select('id, name, role') // Adjust your column names as necessary
          .eq('role', role) // Filter by role
          .range(offset, offset + limit - 1); // Range-based pagination

      // Return the fetched data as a list of maps
      return response;
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }
}
