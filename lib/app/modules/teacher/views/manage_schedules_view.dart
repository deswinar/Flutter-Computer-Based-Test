import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/schedule_controller.dart';
import '../controllers/test_controller.dart';
import 'widgets/date_time_picker.dart';
import 'widgets/manage_card.dart';

class ManageSchedulesView extends StatelessWidget {
  final ScheduleController controller = Get.find<ScheduleController>();
  final TestController testController = Get.find<TestController>();

  ManageSchedulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Schedules', style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.ascending.value
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),
            onPressed: () {
              controller.ascending.toggle();
              controller.fetchSchedules(reset: true);
            },
            tooltip: "Toggle Sorting",
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: Obx(
              () =>
                  controller.isLoading.value && controller.schedules.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : controller.schedules.isEmpty
                      ? const Center(child: Text("No schedules available."))
                      : _buildScheduleList(),
            ),
          ),
          Obx(
            () =>
                controller.isLoading.value
                    ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                    : controller.hasMoreData.value
                    ? TextButton(
                      onPressed: () => controller.fetchSchedules(),
                      child: const Text("Load More"),
                    )
                    : const SizedBox(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSchedule,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 🔍 **Search Bar**
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (query) {
          controller.searchQuery.value = query;
          controller.fetchSchedules(reset: true);
        },
        decoration: const InputDecoration(
          hintText: "Search schedules...",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  /// 📅 **Schedule List with Cards**
  Widget _buildScheduleList() {
    final filteredSchedules =
        controller.schedules
            .where(
              (schedule) =>
                  schedule['tests']?['title']?.toLowerCase().contains(
                    controller.searchQuery.value.toLowerCase(),
                  ) ??
                  false,
            )
            .toList();

    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredSchedules.isEmpty) {
      return const Center(
        child: Text(
          "No schedules available.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSchedules.length,
      itemBuilder: (context, index) {
        final schedule = filteredSchedules[index];

        return ManageCard(
          title: schedule['tests']['title'],
          subtitle:
              "Start: ${_formatDateTime(schedule['start_time'])}\nEnd: ${_formatDateTime(schedule['end_time'])}",
          onTap: () => _editSchedule(schedule),
          onEdit: () => _editSchedule(schedule),
          onDelete: () => _confirmDelete(schedule['id']),
        );
      },
    );
  }

  /// ➕ **Add New Schedule**
  void _addNewSchedule() {
    String? selectedTestId;
    DateTime? startTime;
    DateTime? endTime;

    Get.bottomSheet(
      _scheduleBottomSheet(
        title: "Add Schedule",
        onSave: () {
          if (selectedTestId != null && startTime != null && endTime != null) {
            controller.addSchedule(selectedTestId!, startTime!, endTime!);
            Get.back();
          } else {
            Get.snackbar("Error", "Please fill all fields");
          }
        },
        onTestSelected: (testId) => selectedTestId = testId,
        onStartTimePicked: (time) => startTime = time,
        onEndTimePicked: (time) => endTime = time,
      ),
      isScrollControlled: true,
    );
  }

  /// ✏️ **Edit Schedule**
  void _editSchedule(Map<String, dynamic> schedule) {
    DateTime startTime = DateTime.parse(schedule['start_time']);
    DateTime endTime = DateTime.parse(schedule['end_time']);

    Get.bottomSheet(
      _scheduleBottomSheet(
        title: "Edit Schedule",
        initialStartTime: startTime,
        initialEndTime: endTime,
        onSave: () {
          controller.updateSchedule(schedule['id'], startTime, endTime);
          Get.back();
        },
        onStartTimePicked: (time) => startTime = time,
        onEndTimePicked: (time) => endTime = time,
        isEditing: true,
      ),
      isScrollControlled: true,
    );
  }

  /// 🗑 **Delete Confirmation**
  void _confirmDelete(String scheduleId) {
    Get.defaultDialog(
      title: "Confirm Delete",
      middleText: "Are you sure you want to delete this schedule?",
      textCancel: "Cancel",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteSchedule(scheduleId);
        Get.back();
      },
    );
  }

  /// 📅 **Bottom Sheet for Add/Edit Schedule**
  Widget _scheduleBottomSheet({
    required String title,
    DateTime? initialStartTime,
    DateTime? initialEndTime,
    required VoidCallback onSave,
    required Function(DateTime) onStartTimePicked,
    required Function(DateTime) onEndTimePicked,
    Function(String)? onTestSelected,
    bool isEditing = false,
  }) {
    TextEditingController searchController = TextEditingController();
    RxString selectedTestTitle = "".obs;
    ScrollController scrollController = ScrollController();

    // Reactive variables for time
    Rx<DateTime?> selectedStartTime = Rx<DateTime?>(initialStartTime);
    Rx<DateTime?> selectedEndTime = Rx<DateTime?>(initialEndTime);

    void loadMore() {
      if (testController.hasMoreData.value &&
          !testController.isLoadingMore.value) {
        testController.loadMoreTests();
      }
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        loadMore();
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          if (!isEditing) ...[
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: "Search Test",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                testController.setSearchQuery(query);
              },
            ),
            const SizedBox(height: 16),

            Obx(
              () =>
                  selectedTestTitle.value.isNotEmpty
                      ? Text(
                        "Selected Test: ${selectedTestTitle.value}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue,
                        ),
                      )
                      : const SizedBox(),
            ),

            const SizedBox(height: 8),

            Obx(
              () => Expanded(
                child:
                    testController.tests.isEmpty &&
                            !testController.isLoading.value
                        ? const Center(child: Text("No tests available."))
                        : ListView.builder(
                          controller: scrollController,
                          itemCount:
                              testController.tests.length +
                              (testController.hasMoreData.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < testController.tests.length) {
                              final test = testController.tests[index];
                              return ListTile(
                                title: Text(test['title']),
                                onTap: () {
                                  selectedTestTitle.value = test['title'];
                                  onTestSelected?.call(test['id'].toString());
                                },
                                trailing: Obx(
                                  () =>
                                      selectedTestTitle.value == test['title']
                                          ? const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          )
                                          : const SizedBox.shrink(),
                                ),
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
              ),
            ),
          ],

          const SizedBox(height: 16),
          Obx(
            () => DateTimePicker(
              label: "Start Time",
              onDateTimePicked: onStartTimePicked,
              initialValue: selectedStartTime.value,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DateTimePicker(
              label: "End Time",
              onDateTimePicked: onEndTimePicked,
              initialValue: selectedEndTime.value,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onSave, child: const Text("Save Schedule")),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    return DateTime.parse(dateTime).toLocal().toString().split('.')[0];
  }
}
