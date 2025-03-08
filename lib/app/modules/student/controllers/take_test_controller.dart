import 'dart:async';

import 'package:cp_cbt/app/modules/student/controllers/available_tests_controller.dart';
import 'package:get/get.dart';
import '../../../data/repositories/student_answer_repository.dart';
import '../../../data/repositories/student_test_repository.dart';
import '../../../routes/app_pages.dart';

class TakeTestController extends GetxController {
  final StudentTestRepository _studentTestRepository = StudentTestRepository();
  final StudentAnswerRepository _studentAnswerRepository =
      StudentAnswerRepository();

  var test = {}.obs;
  var studentTestId = ''.obs;
  var questions = <Map<String, dynamic>>[].obs;
  var currentQuestionIndex = 0.obs;
  var selectedAnswer = RxnInt();
  var isSubmitting = false.obs;

  // **Countdown Timer Variables**
  var remainingTime = ''.obs; // Formatted HH:MM:SS
  Timer? _timer;
  DateTime? testEndTime;

  // Store loaded answers once
  final Map<int, int> storedAnswers = {};

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;

    if (args == null ||
        args['student_test_id'] == null ||
        args['test'] == null) {
      Get.snackbar("Error", "Invalid test data");
      return;
    }

    studentTestId.value = args['student_test_id'].toString();
    test.value = args['test'];
    questions.value = args['test']['questions'] ?? [];

    // **Initialize Countdown Timer**
    _initializeTimer();

    // Load stored answers once
    storedAnswers.addAll(
      _studentTestRepository.loadStoredAnswers(questions.length),
    );

    // Set the first question's stored answer if available
    selectedAnswer.value = getSelectedAnswer(0);
  }

  /// **Initialize Timer**
  Future<void> _initializeTimer() async {
    try {
      var studentTest = await _studentTestRepository.getTestDetails(
        studentTestId.value,
      );

      // Validate response
      if (studentTest == null ||
          !studentTest.containsKey('started_at') ||
          !studentTest.containsKey('test') ||
          !studentTest['test'].containsKey('duration')) {
        print("Error: 'started_at' or 'duration' missing in test data");
        return;
      }

      String? startedAtString = studentTest['started_at']; // ✅ Correct key
      int durationMinutes =
          studentTest['test']['duration']; // ✅ Correct key for duration

      if (startedAtString == null) {
        print("Error: 'started_at' is null");
        return;
      }

      DateTime startedAt = DateTime.parse(
        startedAtString,
      ); // Convert to DateTime
      testEndTime = startedAt.add(
        Duration(minutes: durationMinutes),
      ); // Compute end time

      _updateTimer(); // Initial update
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateTimer();
      });
    } catch (e) {
      print("Error initializing timer: $e");
    }
  }

  /// **Update Timer UI**
  void _updateTimer() {
    if (testEndTime == null) return;

    Duration remaining = testEndTime!.difference(DateTime.now());

    if (remaining.isNegative) {
      remainingTime.value = "00:00:00";
      _timer?.cancel();
      finishTest(); // Auto-submit when time runs out
    } else {
      remainingTime.value = _formatDuration(remaining);
    }
  }

  /// **Format Time as HH:MM:SS**
  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  /// Ensure two-digit formatting
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  /// Load answer for a specific question index
  void loadAnswerForQuestion(int index) {
    currentQuestionIndex.value = index;
    selectedAnswer.value =
        _studentTestRepository.loadStoredAnswers(questions.length)[index];
  }

  /// Get selected answer for a specific question
  int? getSelectedAnswer(int index) {
    return storedAnswers[index];
  }

  /// Handle navigation when a question is selected from the navigation bar
  void selectQuestion(int index) {
    currentQuestionIndex.value = index;
    selectedAnswer.value = getSelectedAnswer(index);
  }

  /// Save the selected answer
  void saveAnswer(int answerIndex) {
    int currentIndex = currentQuestionIndex.value;
    selectedAnswer.value = answerIndex;
    storedAnswers[currentIndex] = answerIndex;

    // Save locally
    _studentTestRepository.saveAnswer(currentIndex, answerIndex);
  }

  Future<void> finishTest() async {
    isSubmitting.value = true;

    _timer?.cancel(); // Stop the timer
    _timer = null;

    bool success = await _studentAnswerRepository.finishTest(
      studentTestId.value,
      questions, // Assuming this contains the question list
    );

    isSubmitting.value = false;

    if (success) {
      Get.snackbar("Success", "Test submitted successfully!");

      // ✅ Extract question IDs from the test
      List<String> questionIds =
          questions.map((q) => q['id'].toString()).toList();
      _studentTestRepository.clearSavedAnswers(questionIds);

      // ✅ Mark test as completed in AvailableTestsController
      final availableTestsController = Get.find<AvailableTestsController>();
      availableTestsController.markTestAsCompleted(studentTestId.value);

      Get.offAllNamed(Routes.STUDENT_DASHBOARD);
    } else {
      Get.snackbar("Error", "Failed to submit test.");
    }
  }
}
