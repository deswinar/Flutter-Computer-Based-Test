import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/schedule_repository.dart';

class ScheduleController extends GetxController {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();
  final AuthRepository _authRepository = AuthRepository();

  RxList<Map<String, dynamic>> schedules = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = "".obs;
  RxString sortBy = "start_time".obs;
  RxBool ascending = true.obs;
  RxInt limit = 10.obs;
  RxInt offset = 0.obs;
  RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
  }

  Future<void> fetchSchedules({bool reset = false}) async {
    if (reset) {
      offset.value = 0;
      schedules.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value) return;

    isLoading.value = true;
    try {
      String? teacherId = _authRepository.currentUserId;
      if (teacherId == null) throw Exception("User not authenticated");
      List<Map<String, dynamic>> result = await _scheduleRepository
          .getSchedules(
            teacherId: teacherId,
            searchQuery: searchQuery.value,
            sortBy: sortBy.value,
            ascending: ascending.value,
            limit: limit.value,
            offset: offset.value,
          );

      if (reset) {
        schedules.assignAll(result);
      } else {
        schedules.addAll(result);
      }

      hasMoreData.value = result.length == limit.value;
      offset.value += limit.value;
    } catch (e) {
      Get.snackbar("Error", "Failed to load schedules: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSchedule(
    String testId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      await _scheduleRepository.createSchedule(testId, startTime, endTime);
      fetchSchedules(reset: true);
    } catch (e) {
      Get.snackbar("Error", "Failed to add schedule: $e");
    }
  }

  Future<void> updateSchedule(
    String scheduleId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      await _scheduleRepository.updateSchedule(scheduleId, startTime, endTime);
      fetchSchedules(reset: true);
    } catch (e) {
      Get.snackbar("Error", "Failed to update schedule: $e");
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    try {
      await _scheduleRepository.deleteSchedule(scheduleId);
      fetchSchedules(reset: true);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete schedule: $e");
    }
  }
}
