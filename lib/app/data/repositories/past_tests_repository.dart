import 'package:supabase_flutter/supabase_flutter.dart';

class PastTestsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPastTests({
    required String studentId,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = "completed_at",
    bool ascending = false,
  }) async {
    try {
      // Start with the base query
      var query = _supabase.from('student_tests').select('''
            id, score, status, started_at, completed_at,
            schedules(start_time, end_time, tests(title, description))
          ''');

      // Apply filters
      query = query.eq('student_id', studentId).eq('status', 'completed');

      if (startDate != null) {
        DateTime adjustedStart = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          0,
          0,
          0,
        );
        query = query.gte('completed_at', adjustedStart.toIso8601String());
      }

      if (endDate != null) {
        DateTime adjustedEnd = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        query = query.lte('completed_at', adjustedEnd.toIso8601String());
      }

      // Fetch results with sorting
      final response = await query.order(sortBy, ascending: ascending);

      return response.map<Map<String, dynamic>>((test) => test).toList();
    } catch (e) {
      print("Error fetching past tests: $e");
      return [];
    }
  }
}
