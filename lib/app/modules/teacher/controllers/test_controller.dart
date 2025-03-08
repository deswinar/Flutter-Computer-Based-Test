import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/test_repository.dart';

class TestController extends GetxController {
  final TestRepository _testRepository = TestRepository();
  final AuthRepository _authRepository = AuthRepository();

  RxList<Map<String, dynamic>> tests = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMoreData = true.obs;

  RxString searchQuery = "".obs;
  Rxn<DateTime> startDate = Rxn<DateTime>();
  Rxn<DateTime> endDate = Rxn<DateTime>();
  RxString sortBy = "created_at".obs;
  RxBool ascending = false.obs;

  int limit = 10;
  int page = 0;

  @override
  void onInit() {
    super.onInit();
    fetchTests();
  }

  Future<void> fetchTests({bool reset = true}) async {
    if (reset) {
      isLoading.value = true;
      page = 0;
      tests.clear();
      hasMoreData.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      String? teacherId = _authRepository.currentUserId;
      if (teacherId == null) throw Exception("User not authenticated");

      List<Map<String, dynamic>> result = await _testRepository.getTests(
        teacherId,
        limit: limit,
        offset: page * limit,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        startDate: startDate.value,
        endDate: endDate.value,
        sortBy: sortBy.value,
        ascending: ascending.value,
      );

      if (reset) {
        tests.assignAll(result);
      } else {
        tests.addAll(result);
      }

      hasMoreData.value = result.length >= limit;
      if (hasMoreData.value) page++;
    } catch (e) {
      Get.snackbar("Error", "Failed to load tests: $e");
    }

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  Future<void> loadMoreTests() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    await fetchTests(reset: false);
  }

  Future<void> createTest(
    String title,
    String description,
    int duration,
  ) async {
    try {
      String? teacherId = _authRepository.currentUserId;
      if (teacherId == null) throw Exception("User not authenticated");

      await _testRepository.createTest(title, description, teacherId, duration);
      fetchTests();
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to create test: $e");
    }
  }

  Future<void> updateTest(
    String testId,
    String title,
    String description,
    int duration,
  ) async {
    try {
      await _testRepository.updateTest(testId, title, description, duration);
      fetchTests();
      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Failed to update test: $e");
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      await _testRepository.deleteTest(testId);
      fetchTests();
    } catch (e) {
      Get.snackbar("Error", "Failed to delete test: $e");
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    fetchTests();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    fetchTests();
  }

  void setSorting(String field, {bool asc = true}) {
    sortBy.value = field;
    ascending.value = asc;
    fetchTests();
  }

  /// **Clears all filters and resets to default**
  void clearFilters() {
    searchQuery.value = "";
    startDate.value = null;
    endDate.value = null;
    sortBy.value = "created_at";
    ascending.value = false;
    fetchTests();
  }
}
