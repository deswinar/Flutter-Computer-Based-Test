import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/past_tests_repository.dart';
import '../../../routes/app_pages.dart';

class PastTestsController extends GetxController {
  final PastTestsRepository _pastTestRepository = PastTestsRepository();
  final AuthRepository _authRepository = AuthRepository();

  var pastTests = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var selectedSort = 'Completed At'.obs;
  var selectedStartDate = Rxn<DateTime>();
  var selectedEndDate = Rxn<DateTime>();
  var isFilterApplied = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPastTests();
  }

  Future<void> fetchPastTests() async {
    isLoading.value = true;
    try {
      String? studentId = _authRepository.currentUserId;
      if (studentId == null) throw Exception("User not authenticated");

      final sortOptions = {'Completed At': 'completed_at', 'Score': 'score'};

      final tests = await _pastTestRepository.fetchPastTests(
        studentId: studentId,
        startDate: selectedStartDate.value,
        endDate: selectedEndDate.value,
        sortBy:
            sortOptions[selectedSort.value] ??
            'completed_at', // Convert UI name to DB column
      );

      pastTests.assignAll(tests);
      isFilterApplied.value =
          selectedStartDate.value != null || selectedEndDate.value != null;
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void updateSort(String sortOption) {
    selectedSort.value = sortOption;
    fetchPastTests(); // Fetch sorted data from server
  }

  void updateDateRange(DateTime start, DateTime end) {
    selectedStartDate.value = start;
    selectedEndDate.value = end;
    fetchPastTests(); // Fetch filtered data from server
  }

  void clearFilters() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedSort.value = 'Completed At';
    fetchPastTests(); // Reload unfiltered data from server
    isFilterApplied.value = false;
  }

  void navigateToTestDetails(String studentTestId) {
    Get.toNamed(
      Routes.TEST_DETAILS,
      arguments: {'student_test_id': studentTestId},
    );
  }

  void navigateToRanking(String scheduleId) {
    Get.toNamed('/test-ranking', arguments: {'schedule_id': scheduleId});
  }
}
