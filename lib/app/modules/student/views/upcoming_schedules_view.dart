import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upcoming_schedules_controller.dart';

class UpcomingSchedulesView extends StatelessWidget {
  final UpcomingSchedulesController controller = Get.put(
    UpcomingSchedulesController(),
  );

  UpcomingSchedulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upcoming Schedules")),
      body: Column(
        children: [
          // Filter & Sort Options
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter Dropdown
                DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  items:
                      ['All', 'This Week']
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateFilter(value);
                    }
                  },
                ),

                // Sort Dropdown
                DropdownButton<String>(
                  value: controller.selectedSort.value,
                  items:
                      ['Start Time']
                          .map(
                            (sort) => DropdownMenuItem(
                              value: sort,
                              child: Text(sort),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      controller.updateSort(value);
                    }
                  },
                ),
              ],
            ),
          ),

          // Schedules List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.filteredSchedules.isEmpty) {
                return Center(child: Text("No upcoming schedules"));
              }

              return ListView.builder(
                itemCount: controller.filteredSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = controller.filteredSchedules[index];

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(schedule['tests']['title'] ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule['tests']['description'] ??
                                'No Description',
                          ),
                          SizedBox(height: 5),
                          Text("Start: ${schedule['start_time']}"),
                          Text(
                            "Duration: ${schedule['tests']['duration']} minutes",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
