import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add a Question to a Test
  Future<void> addQuestion(
    String testId,
    String questionText,
    List<String> options,
    int correctAnswer,
    int questionNumber,
  ) async {
    await _supabase.from('questions').insert({
      'test_id': testId,
      'question_text': questionText,
      'options': options, // JSONB in Supabase
      'correct_answer': correctAnswer,
      'question_number': questionNumber,
    });
  }

  // Get Questions for a Specific Test (Ordered by question_number)
  Future<List<Map<String, dynamic>>> getQuestions(String testId) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('test_id', testId)
        .order('question_number', ascending: true); // Order by question number
    return response;
  }

  // Get the number of questions for a specific test
  Future<int> getQuestionCount(String testId) async {
    final response = await _supabase
        .from('questions')
        .select('id') // Select a column before counting
        .eq('test_id', testId)
        .count(CountOption.exact); // Get exact count

    print(testId);

    return response.count; // Ensure a valid return value
  }

  // Update Question Order
  Future<void> updateQuestionOrder(List<Map<String, dynamic>> questions) async {
    for (var question in questions) {
      await _supabase
          .from('questions')
          .update({'question_number': question['question_number']})
          .eq('id', question['id']);
    }
  }

  // Update a Question
  Future<void> updateQuestion(
    String questionId,
    String questionText,
    List<String> options,
    int correctAnswer,
    int questionNumber,
  ) async {
    await _supabase
        .from('questions')
        .update({
          'question_text': questionText,
          'options': options,
          'correct_answer': correctAnswer,
          'question_number': questionNumber,
        })
        .eq('id', questionId);
  }

  // Delete a Question
  Future<void> deleteQuestion(String questionId) async {
    await _supabase.from('questions').delete().eq('id', questionId);
  }
}
