import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/test_repository.dart';

class TeacherController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final TestRepository _testRepository = TestRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final QuestionRepository _questionRepository = QuestionRepository();

  var teacherName = "".obs;
  var testCount = 0.obs;
  var questionCount = 0.obs;
  var ongoingScheduleCount = 0.obs;
  var futureScheduleCount = 0.obs;
  var recentActivity = <String>[].obs;
  var isLoading = true.obs;

  String? teacherId;

  @override
  void onInit() {
    super.onInit();
    loadTeacherData();
  }

  Future<void> loadTeacherData() async {
    try {
      isLoading.value = true;

      // Get the logged-in user ID
      teacherId = _authRepository.currentUserId;
      if (teacherId == null) {
        Get.snackbar("Error", "User not found");
        return;
      }

      // Fetch user data (name and role)
      final userData = await _authRepository.getUserData(teacherId!);
      if (userData == null || userData['role'] != 'teacher') {
        Get.snackbar("Error", "Invalid user role");
        return;
      }

      teacherName.value = userData['name'];

      // Fetch dashboard data
      await fetchDashboardData();
    } catch (e) {
      Get.snackbar("Error", "Failed to load teacher data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      teacherId = _authRepository.currentUserId;
      if (teacherId == null) {
        Get.snackbar("Error", "User not found");
        return;
      }
      isLoading.value = true;

      // Fetch tests
      final tests = await _testRepository.getTests(
        teacherId!,
        limit: 10,
        offset: 0,
      );
      testCount.value = tests.length;

      // Fetch questions (assuming questions are linked to tests)
      int totalQuestions = 0;
      for (var test in tests) {
        final questions = await _questionRepository.getQuestions(test['id']);
        totalQuestions += questions.length;
      }
      questionCount.value = totalQuestions;

      // Fetch schedules (assuming schedules represent student bookings)
      final schedules = await _scheduleRepository.getSchedules(
        teacherId: teacherId!,
        limit: 10,
        offset: 0,
      );

      // Filter schedules into ongoing and future
      final ongoingSchedules = <Map<String, dynamic>>[];
      final futureSchedules = <Map<String, dynamic>>[];
      final now = DateTime.now();

      for (var schedule in schedules) {
        DateTime scheduleDate = DateTime.parse(
          schedule['start_time'],
        ); // Assuming `schedule_date` is in ISO 8601 format
        // Check if the schedule is ongoing or future
        if (scheduleDate.isBefore(now) &&
            now.isBefore(scheduleDate.add(Duration(hours: 2)))) {
          ongoingSchedules.add(schedule); // Ongoing schedules
        } else if (scheduleDate.isAfter(now)) {
          futureSchedules.add(schedule); // Future schedules
        }
      }
      // Set the counts for ongoing and future schedules
      ongoingScheduleCount.value = ongoingSchedules.length;
      futureScheduleCount.value = futureSchedules.length;
      // Fetch recent activity (based on test updates)
      recentActivity.assignAll(
        tests
            .take(3)
            .map((test) => "Updated Test: ${test['title'] ?? 'Untitled Test'}"),
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to load dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _authRepository.signOut();
    Get.offAllNamed("/login"); // Redirect to login screen
  }
}
