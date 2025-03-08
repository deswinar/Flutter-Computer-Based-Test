import 'package:supabase_flutter/supabase_flutter.dart';

class ScheduleRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getSchedules({
    required String teacherId,
    required int limit,
    required int offset,
    String? searchQuery,
    String sortBy = "start_time",
    bool ascending = true,
  }) async {
    var query = _supabase
        .from('schedules')
        .select('id, test_id, start_time, end_time, tests(title, description)')
        .eq('tests.created_by', teacherId);

    // Apply search filter if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('tests.title', '%$searchQuery%');
    }

    final response = await query
        .order(sortBy, ascending: ascending)
        .range(offset, offset + limit - 1);

    return response; // Ensure it returns an empty list instead of null
  }

  Future<void> createSchedule(
    String testId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    await _supabase.from('schedules').insert({
      'test_id': testId,
      'start_time': startTime.toUtc().toIso8601String(),
      'end_time': endTime.toUtc().toIso8601String(),
    });
  }

  Future<void> updateSchedule(
    String scheduleId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    await _supabase
        .from('schedules')
        .update({
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': endTime.toUtc().toIso8601String(),
        })
        .eq('id', scheduleId);
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _supabase.from('schedules').delete().eq('id', scheduleId);
  }

  Future<int> getUpcomingScheduleCount(String userId) async {
    final response = await _supabase
        .from('schedules')
        .select('id') // Select a column before counting
        .gte('start_time', DateTime.now().toIso8601String()) // Future schedules
        .count(CountOption.exact); // Get exact count

    return response.count; // Ensure a valid return value
  }

  Future<List<Map<String, dynamic>>> getAvailableTests(String studentId) async {
    final DateTime now = DateTime.now().toUtc(); // Ensure UTC time
    final String todayStart =
        DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final String todayEnd =
        DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    print("Query Start Time: $todayStart");
    print("Query End Time: $todayEnd");

    final response = await _supabase
        .from('schedules')
        .select('''
        id, test_id, start_time, end_time, 
        tests(title, description, duration), 
        student_tests!left(status)
        ''')
        .eq('student_tests.student_id', studentId) // Filter by student
        .lte(
          'start_time',
          todayEnd,
        ) // Include schedules that started before today
        .gte('end_time', todayStart) // Include active schedules
        .order('start_time', ascending: true);

    print("Supabase Response: $response");

    return response.map((test) {
      return {
        ...test,
        'status':
            test['student_tests']?.isNotEmpty == true
                ? test['student_tests'][0]['status']
                : null, // Get the test status if available
      };
    }).toList();
  }

  Future<int> getAvailableTestCount(String studentId) async {
    final DateTime now = DateTime.now().toUtc();
    final String todayStart =
        DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final String todayEnd =
        DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    print("Query Start Time: $todayStart");
    print("Query End Time: $todayEnd");

    final response = await _supabase
        .from('schedules')
        .select(
          'id, student_tests!inner(student_id)',
        ) // Ensure relation is joined
        .eq('student_tests.student_id', studentId) // Filter by student
        .lte(
          'start_time',
          todayEnd,
        ) // Include schedules that started before today
        .gte('end_time', todayStart) // Include active schedules
        .count(CountOption.exact); // Get exact count

    print("Available Test Count: $response");

    return response.count; // Return 0 if no records found
  }

  // Upcoming Schedules
  Future<List<Map<String, dynamic>>> getUpcomingSchedules() async {
    final DateTime now = DateTime.now().toUtc();

    final response = await _supabase
        .from('schedules')
        .select('''
        id, test_id, start_time, end_time, 
        tests(title, description)
      ''')
        .gte('start_time', now.toIso8601String()) // Get only future schedules
        .order('start_time', ascending: true);

    return response;
  }
}
