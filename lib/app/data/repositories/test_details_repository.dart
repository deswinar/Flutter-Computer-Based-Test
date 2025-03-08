import 'package:supabase_flutter/supabase_flutter.dart';

class TestDetailsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getTestDetails(String studentTestId) async {
    final response =
        await _supabase
            .from('student_tests')
            .select('''
          id,
          score,
          status,
          started_at,
          completed_at,
          schedule_id,
          schedules (
            test_id,
            tests (
              title,
              description,
              duration
            )
          ),
          student_answers (
            question_id,
            selected_answer,
            questions (
              question_text,
              options,
              correct_answer,
              question_number
            )
          )
        ''')
            .eq('id', studentTestId)
            .single(); // Fetch a single row since student_test_id is unique

    if (response == null) {
      throw Exception('No test details found.');
    }

    // Extract test details
    final testInfo = response['schedules']['tests'];
    final studentAnswers = List<Map<String, dynamic>>.from(
      response['student_answers'],
    );

    // Sort questions by question_number
    studentAnswers.sort(
      (a, b) => (a['questions']['question_number'] as int).compareTo(
        b['questions']['question_number'] as int,
      ),
    );

    return {
      'test': {
        'title': testInfo['title'],
        'description': testInfo['description'],
        'duration': testInfo['duration'],
      },
      'student_test': {
        'score': response['score'],
        'status': response['status'],
        'started_at': response['started_at'],
        'completed_at': response['completed_at'],
      },
      'questions': studentAnswers,
    };
  }
}
