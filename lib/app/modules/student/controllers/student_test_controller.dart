import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/student_answer_repository.dart';
import '../../../data/repositories/student_test_repository.dart';
import '../../../routes/app_pages.dart';

class StudentTestController {
  final StudentTestRepository _studentTestRepository = StudentTestRepository();
  final StudentAnswerRepository _studentAnswerRepository =
      StudentAnswerRepository();
  final AuthRepository _authRepository = AuthRepository();

  var isLoading = false.obs;

  /// Get available tests for a student
  Future<List<Map<String, dynamic>>> fetchAvailableTests(
    String studentId,
  ) async {
    return await _studentTestRepository.getAvailableTests(studentId);
  }

  /// Start a test
  /// Start test process
  Future<void> startTest(Map<String, dynamic> test) async {
    String? studentId = _authRepository.currentUserId;
    if (studentId == null) throw Exception("User not authenticated");

    isLoading.value = true;

    final newTestId = await _studentTestRepository.startTest(
      studentId,
      test['id'],
    );

    isLoading.value = false;

    if (newTestId != null) {
      // Ensure it's a String
      Get.toNamed(
        Routes.TAKE_TEST,
        arguments: {'student_test_id': newTestId, 'test': test},
      );
    } else {
      Get.snackbar("Error", "Failed to start test");
    }
  }

  /// Get all submitted answers for a test
  Future<List<Map<String, dynamic>>> fetchStudentAnswers(
    String studentTestId,
  ) async {
    return await _studentAnswerRepository.getStudentAnswers(studentTestId);
  }
}
