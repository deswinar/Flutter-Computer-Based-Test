import 'package:get/get.dart';
import '../../../data/repositories/question_repository.dart';

class QuestionController extends GetxController {
  final QuestionRepository _questionRepository = QuestionRepository();

  RxList<Map<String, dynamic>> questions = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxBool isSaving = false.obs;

  RxString testTitle = "".obs;
  RxString testDescription = "".obs;
  String? testId;

  // Set test ID and fetch questions
  void setTestId(String id) {
    if (testId == id) return;
    testId = id;
    fetchQuestions();
  }

  void setTest(Map<String, dynamic> test) {
    if (testId == test['id']) return;
    testId = test['id'];
    testTitle.value = test['title'];
    testDescription.value = test['description'];
    fetchQuestions();
  }

  // Fetch Questions (Ordered by question_number)
  Future<void> fetchQuestions() async {
    if (testId == null) return;
    isLoading.value = true;
    try {
      final result = await _questionRepository.getQuestions(testId!);
      questions.assignAll(result);
    } catch (e) {
      Get.snackbar("Error", "Failed to load questions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Reorder Questions
  Future<void> reorderQuestions(int oldIndex, int newIndex) async {
    if (testId == null) return;

    final question = questions.removeAt(oldIndex);
    questions.insert(newIndex, question);

    // Update question numbers
    for (int i = 0; i < questions.length; i++) {
      questions[i]['question_number'] = i + 1;
    }

    // Save new order to Supabase
    await _questionRepository.updateQuestionOrder(questions);
  }

  // Add a Question
  Future<void> addQuestion(
    String questionText,
    List<String> options,
    int correctAnswer,
  ) async {
    if (testId == null) return;
    isSaving.value = true;
    try {
      int questionNumber =
          questions.length + 1; // Auto-increment question number

      await _questionRepository.addQuestion(
        testId!,
        questionText,
        options,
        correctAnswer,
        questionNumber,
      );
      fetchQuestions();
      Get.back();
      Get.snackbar("Success", "Question added successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add question: $e");
    } finally {
      isSaving.value = false;
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
    if (testId == null) return;
    isSaving.value = true;
    try {
      await _questionRepository.updateQuestion(
        questionId,
        questionText,
        options,
        correctAnswer,
        questionNumber,
      );
      fetchQuestions();
      Get.back();
      Get.snackbar("Success", "Question updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update question: $e");
    } finally {
      isSaving.value = false;
    }
  }

  // Delete a Question
  Future<void> deleteQuestion(String questionId) async {
    if (testId == null) return;
    isLoading.value = true;
    try {
      await _questionRepository.deleteQuestion(questionId);
      fetchQuestions();
      Get.snackbar("Success", "Question deleted!");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete question: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
