import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentTestRepository {
  final GetStorage _storage = GetStorage();
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all available tests for a student
  Future<List<Map<String, dynamic>>> getAvailableTests(String studentId) async {
    final response = await _supabase
        .from('student_tests')
        .select('*, schedules(*, tests(*))')
        .eq('student_id', studentId)
        .contains('status', ['not_started', 'in_progress']);

    if (response.isEmpty) return [];

    return response;
  }

  /// Start a test (set status to 'in_progress' and store start time)
  Future<String?> startTest(String studentId, String scheduleId) async {
    // Check if there's an existing student_test entry
    final existingTest =
        await _supabase
            .from('student_tests')
            .select('id') // Select only the ID
            .eq('student_id', studentId)
            .eq('schedule_id', scheduleId)
            .or('status.eq.not_started,status.eq.in_progress')
            .maybeSingle();

    if (existingTest != null) {
      // Update existing test entry
      final response = await _supabase
          .from('student_tests')
          .update({
            'status': 'in_progress',
            // 'started_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', existingTest['id'])
          .select('id'); // Retrieve the updated test ID

      return response.isNotEmpty ? response.first['id'] as String? : null;
    } else {
      // Insert new test entry
      final response = await _supabase
          .from('student_tests')
          .insert({
            'student_id': studentId,
            'schedule_id': scheduleId,
            'status': 'in_progress',
            'started_at': DateTime.now().toIso8601String(),
          })
          .select('id'); // Retrieve the inserted test ID

      return response.isNotEmpty ? response.first['id'] as String? : null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchQuestions(String testId) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('test_id', testId)
        .order('question_number', ascending: true); // Ensure ordered list

    return response.isNotEmpty ? List<Map<String, dynamic>>.from(response) : [];
  }

  // Take Test
  /// Save selected answer locally (Now using question ID instead of index)
  void saveAnswer(int questionId, int answerIndex) {
    _storage.write("answer_$questionId", answerIndex);
  }

  /// Load stored answers for all questions
  Map<int, int> loadStoredAnswers(int totalQuestions) {
    Map<int, int> answers = {};
    for (int i = 0; i < totalQuestions; i++) {
      if (_storage.hasData("answer_$i")) {
        answers[i] = _storage.read("answer_$i");
      }
    }
    return answers;
  }

  /// Clear saved answers for a specific test
  /// Clear saved answers for a specific test
  void clearSavedAnswers(List<String> questionIds) {
    for (var questionId in questionIds) {
      String key = "answer_$questionId";
      if (_storage.hasData(key)) {
        _storage.remove(key); // Remove only if it exists
      }
    }
  }

  // Past Tests
  /// Fetch past tests for a student
  Future<List<Map<String, dynamic>>> getPastTests(String studentId) async {
    final response = await _supabase
        .from('student_tests')
        .select('''
          id,
          status,
          score,
          schedules (
            test_id,
            tests (
              id,
              title,
              description
            )
          )
        ''')
        .eq('student_id', studentId)
        .eq('status', 'completed')
        .order('created_at', ascending: false);

    if (response.isEmpty) return [];

    return response.map((test) {
      return {
        'id': test['id'],
        'score': test['score'],
        'test_id': test['schedules']['tests']['id'],
        'title': test['schedules']['tests']['title'],
        'description': test['schedules']['tests']['description'],
      };
    }).toList();
  }

  /// Fetch past test details
  Future<Map<String, dynamic>?> getTestDetails(String studentTestId) async {
    final response =
        await _supabase
            .from('student_tests')
            .select('''
          id,
          status,
          score,
          started_at,
          schedules (
            test_id,
            tests (
              id,
              title,
              description,
              duration,
              questions (
                id,
                question_text,
                correct_answer,
                student_answers (
                  selected_answer
                )
              )
            )
          )
        ''')
            .eq('id', studentTestId)
            .maybeSingle();

    if (response == null || response['schedules'] == null) {
      return null;
    }

    final testData = response['schedules']['tests'];
    final questions = (testData['questions'] as List<dynamic>?) ?? [];

    return {
      'student_test_id': response['id'],
      'score': response['score'],
      'started_at': response['started_at'],
      'test': {
        'test_id': testData['id'],
        'title': testData['title'],
        'description': testData['description'],
        'duration': testData['duration'],
        'questions':
            questions.map((q) {
              return {
                'id': q['id'],
                'question_text': q['question_text'],
                'correct_answer': q['correct_answer'],
                'selected_answer':
                    q['student_answers']?.isNotEmpty ?? false
                        ? q['student_answers'][0]['selected_answer']
                        : null,
              };
            }).toList(),
      },
    };
  }
}
