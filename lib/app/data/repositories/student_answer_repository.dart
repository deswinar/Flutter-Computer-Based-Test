import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentAnswerRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GetStorage _storage = Get.find<GetStorage>();

  /// Submit an answer to a question
  Future<bool> submitAnswer({
    required String studentTestId,
    required String questionId,
    required int selectedAnswer,
  }) async {
    final response =
        await _supabase.from('student_answers').upsert({
          'student_test_id': studentTestId,
          'question_id': questionId,
          'selected_answer': selectedAnswer,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        }).select();

    return response.isNotEmpty;
  }

  /// Get answers for a specific test
  Future<List<Map<String, dynamic>>> getStudentAnswers(
    String studentTestId,
  ) async {
    final response = await _supabase
        .from('student_answers')
        .select('*')
        .eq('student_test_id', studentTestId);

    return response;
  }

  /// **Finish test: Submit all answers stored locally to Supabase**
  Future<bool> finishTest(
    String studentTestId,
    List<Map<String, dynamic>> questions,
  ) async {
    List<Map<String, dynamic>> answersToSubmit = [];
    int correctAnswers = 0;

    for (int i = 0; i < questions.length; i++) {
      int? storedAnswer = _storage.read("answer_$i");

      if (storedAnswer != null) {
        answersToSubmit.add({
          "student_test_id": studentTestId,
          "question_id": questions[i]['id'],
          "selected_answer": storedAnswer,
          "created_at": DateTime.now().toUtc().toIso8601String(),
        });

        // Check if the answer is correct
        if (storedAnswer == questions[i]['correct_answer']) {
          correctAnswers++;
        }
      }
    }

    if (answersToSubmit.isEmpty) {
      return false; // No answers to submit
    }

    bool answersSubmitted = await _submitAnswersToSupabase(answersToSubmit);
    if (!answersSubmitted) return false;

    // Calculate score percentage
    int totalQuestions = questions.length;
    int score = ((correctAnswers / totalQuestions) * 100).round();

    // Update student_tests with completion data
    return await _updateStudentTestRecord(studentTestId, score);
  }

  /// **Update student_tests with completed status & score**
  Future<bool> _updateStudentTestRecord(String studentTestId, int score) async {
    try {
      final response =
          await _supabase
              .from('student_tests')
              .update({
                "status": "completed",
                "completed_at": DateTime.now().toUtc().toIso8601String(),
                "score": score,
              })
              .match({"id": studentTestId})
              .select();

      return response.isNotEmpty;
    } catch (e) {
      print("Error updating student test record: $e");
      return false;
    }
  }

  /// **Submit all student answers to Supabase**
  Future<bool> _submitAnswersToSupabase(
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      final response =
          await _supabase.from('student_answers').upsert(answers).select();

      return response.isNotEmpty;
    } catch (e) {
      print("Error submitting answers: $e");
      return false;
    }
  }
}
