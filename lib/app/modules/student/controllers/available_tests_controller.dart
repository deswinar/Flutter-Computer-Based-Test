import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/student_test_repository.dart';
import '../../../routes/app_pages.dart';

class AvailableTestsController extends GetxController {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final QuestionRepository _questionRepository = QuestionRepository();
  final StudentTestRepository _studentTestRepository = StudentTestRepository();
  final AuthRepository _authRepository = AuthRepository();

  var allTests = <Map<String, dynamic>>[].obs; // Original list
  var filteredTests = <Map<String, dynamic>>[].obs; // Filtered & sorted list
  var isLoading = false.obs;

  var selectedFilter = 'All'.obs; // Default filter
  var selectedSort = 'Start Time'.obs; // Default sort order

  @override
  void onInit() {
    super.onInit();
    fetchAvailableTests();
  }

  Future<void> fetchAvailableTests() async {
    isLoading.value = true;
    try {
      String? studentId = _authRepository.currentUserId;
      if (studentId == null) throw Exception("User not authenticated");

      final tests = await _scheduleRepository.getAvailableTests(studentId);
      print("Fetched tests: $tests"); // Debugging

      final updatedTests = await Future.wait(
        tests.map((test) async {
          final testId = test['test_id'];
          if (testId == null) {
            print("Test ID is null for: $test");
            return test;
          }
          final questionCount = await _questionRepository.getQuestionCount(
            testId,
          );
          test['question_count'] = questionCount;
          return test;
        }),
      );

      allTests.assignAll(updatedTests);
      applyFilters(); // Apply filters after fetching tests
    } catch (e, stackTrace) {
      print("Error fetching available tests: $e\n$stackTrace");
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply filtering and sorting
  void applyFilters() {
    var tempList = List<Map<String, dynamic>>.from(allTests);

    // Apply filter
    if (selectedFilter.value == 'Completed') {
      tempList =
          tempList.where((test) => test['status'] == 'completed').toList();
    } else if (selectedFilter.value == 'Not Completed') {
      tempList =
          tempList.where((test) => test['status'] != 'completed').toList();
    }

    // Apply sorting
    if (selectedSort.value == 'Start Time') {
      tempList.sort(
        (a, b) => (a['start_time'] ?? '').compareTo(b['start_time'] ?? ''),
      );
    } else if (selectedSort.value == 'Question Count') {
      tempList.sort(
        (a, b) =>
            (a['question_count'] ?? 0).compareTo(b['question_count'] ?? 0),
      );
    }

    filteredTests.assignAll(tempList);
  }

  /// Update filter and reapply filters
  void updateFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  /// Update sort order and reapply sorting
  void updateSort(String sortOption) {
    selectedSort.value = sortOption;
    applyFilters();
  }

  /// Start test process
  Future<void> startTest(Map<String, dynamic> test) async {
    String? studentId = _authRepository.currentUserId;
    if (studentId == null) throw Exception("User not authenticated");

    isLoading.value = true;

    final newTestId = await _studentTestRepository.startTest(
      studentId,
      test['id'],
    );

    if (newTestId == null) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to start test");
      return;
    }

    // ✅ Fetch questions from database
    final questions = await _studentTestRepository.fetchQuestions(
      test['test_id'],
    );

    isLoading.value = false;

    if (questions.isEmpty) {
      Get.snackbar("Error", "No questions found for this test.");
      return;
    }

    Get.toNamed(
      Routes.TAKE_TEST,
      arguments: {
        'student_test_id': newTestId,
        'test': {
          ...test, // Keep original test data
          'questions': questions, // Attach fetched questions
        },
      },
    );
  }

  /// Mark a test as completed and refresh the UI
  void markTestAsCompleted(String studentTestId) {
    int index = allTests.indexWhere(
      (test) => test['student_test']?['id'].toString() == studentTestId,
    );

    if (index != -1) {
      allTests[index]['student_test']['status'] = 'completed';

      // Apply filters again to update the displayed list
      applyFilters();
    }
  }
}
