import 'package:get/get.dart';
import '../../../data/repositories/schedule_repository.dart';

class UpcomingSchedulesController extends GetxController {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  var upcomingSchedules = <Map<String, dynamic>>[].obs;
  var filteredSchedules = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Sorting & Filtering
  var selectedSort = 'Start Time'.obs;
  var selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingSchedules();
  }

  Future<void> fetchUpcomingSchedules() async {
    isLoading.value = true;
    try {
      final schedules = await _scheduleRepository.getUpcomingSchedules();
      upcomingSchedules.assignAll(schedules);
      applyFilters();
    } catch (e) {
      print("Error fetching upcoming schedules: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(upcomingSchedules);

    // Apply filter
    if (selectedFilter.value == 'This Week') {
      filtered =
          filtered.where((schedule) {
            final DateTime startTime = DateTime.parse(schedule['start_time']);
            final DateTime now = DateTime.now();
            final DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));
            return startTime.isAfter(now) && startTime.isBefore(endOfWeek);
          }).toList();
    }

    // Apply sorting
    if (selectedSort.value == 'Start Time') {
      filtered.sort(
        (a, b) => DateTime.parse(
          a['start_time'],
        ).compareTo(DateTime.parse(b['start_time'])),
      );
    }

    filteredSchedules.assignAll(filtered);
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    applyFilters();
  }

  void updateSort(String sort) {
    selectedSort.value = sort;
    applyFilters();
  }
}
