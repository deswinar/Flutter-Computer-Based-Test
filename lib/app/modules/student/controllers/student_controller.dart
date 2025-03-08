import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/test_repository.dart';
import '../../../data/repositories/schedule_repository.dart';

class StudentController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final TestRepository _testRepository = TestRepository();
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  var studentId = ''.obs;
  var studentName = ''.obs;
  var isLoading = false.obs;
  var testCount = 0.obs;
  var upcomingScheduleCount = 0.obs;
  var recentTests = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    isLoading.value = true;

    final user = _authRepository.getCurrentUser();
    if (user == null) {
      isLoading.value = false;
      return;
    }

    studentId.value = user.id;
    final userData = await _authRepository.getUserData(user.id);
    studentName.value = userData?['name'] ?? '';

    // Fetch available tests count instead of created test count
    final results = await Future.wait([
      _scheduleRepository.getAvailableTestCount(
        studentId.value,
      ), // Fetch available tests
      _scheduleRepository.getUpcomingScheduleCount(studentId.value),
      _testRepository.getRecentTests(studentId.value),
    ]);

    // Assign fetched data
    testCount.value = results[0] as int; // Count available tests
    upcomingScheduleCount.value = results[1] as int;
    recentTests.value = results[2] as List<String>;

    isLoading.value = false;
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    studentId.value = '';
    studentName.value = '';
    testCount.value = 0;
    upcomingScheduleCount.value = 0;
    recentTests.clear();
    Get.offAllNamed('/login');
  }
}
