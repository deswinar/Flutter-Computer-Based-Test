import 'package:supabase_flutter/supabase_flutter.dart';

class TestRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createTest(
    String title,
    String description,
    String teacherId,
    int duration,
  ) async {
    await _supabase.from('tests').insert({
      'title': title,
      'description': description,
      'created_by': teacherId,
      'duration': duration,
    });
  }

  Future<List<Map<String, dynamic>>> getTests(
    String teacherId, {
    required int limit,
    required int offset,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = "created_at",
    bool ascending = false,
  }) async {
    var query = _supabase.from('tests').select().eq('created_by', teacherId);

    if (search != null && search.isNotEmpty) {
      query = query.ilike('title', '%$search%');
    }

    if (startDate != null) {
      // Set start date to 00:00:00
      DateTime adjustedStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        0,
        0,
        0,
      );
      query = query.gte('created_at', adjustedStart.toIso8601String());
    }

    if (endDate != null) {
      // Set end date to 23:59:59
      DateTime adjustedEnd = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      query = query.lte('created_at', adjustedEnd.toIso8601String());
    }

    final response = await query
        .order(sortBy, ascending: ascending)
        .range(offset, offset + limit - 1);

    return response;
  }

  Future<void> updateTest(
    String testId,
    String title,
    String description,
    int duration,
  ) async {
    await _supabase
        .from('tests')
        .update({
          'title': title,
          'description': description,
          'duration': duration,
        })
        .eq('id', testId);
  }

  Future<void> deleteTest(String testId) async {
    await _supabase.from('tests').delete().eq('id', testId);
  }

  /// Returns the total number of tests created by the user (teacher or student).
  Future<int> getTestCount(String userId) async {
    final response = await _supabase
        .from('tests')
        .select('id') // Selecting any column (e.g., 'id') is necessary
        .eq('created_by', userId)
        .count(CountOption.exact); // Corrected count retrieval

    return response.count;
  }

  /// Returns the most recent tests for a user.
  Future<List<String>> getRecentTests(String userId, {int limit = 3}) async {
    final response = await _supabase
        .from('tests')
        .select('title')
        .eq('created_by', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return response.map<String>((test) => test['title'] as String).toList();
  }
}
