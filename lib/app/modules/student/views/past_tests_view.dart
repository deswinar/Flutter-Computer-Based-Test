import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/past_tests_controller.dart';
import 'package:intl/intl.dart';

class PastTestsView extends StatelessWidget {
  final PastTestsController controller = Get.put(PastTestsController());

  PastTestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Past Tests")),
      body: Column(
        children: [
          // Filter & Sorting Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Date Range Picker
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            DateTimeRange? picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              controller.updateDateRange(
                                picked.start,
                                picked.end,
                              );
                            }
                          },
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            controller.selectedStartDate.value != null &&
                                    controller.selectedEndDate.value != null
                                ? "${DateFormat.yMMMd().format(controller.selectedStartDate.value!)} - ${DateFormat.yMMMd().format(controller.selectedEndDate.value!)}"
                                : "Select Date Range",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sort Dropdown
                      Expanded(
                        child: Obx(
                          () => DropdownButtonFormField<String>(
                            value: controller.selectedSort.value,
                            decoration: const InputDecoration(
                              labelText: "Sort By",
                              border: OutlineInputBorder(),
                            ),
                            items:
                                ['Completed At', 'Score']
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
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Clear Filters Button
                Obx(
                  () => Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed:
                          controller.isFilterApplied.value
                              ? controller.clearFilters
                              : null,
                      icon: const Icon(Icons.clear),
                      label: const Text("Clear Filters"),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            controller.isFilterApplied.value
                                ? Colors.red
                                : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Test List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.pastTests.isEmpty) {
                return const Center(child: Text("No past tests available"));
              }

              return ListView.builder(
                itemCount: controller.pastTests.length,
                itemBuilder: (context, index) {
                  final test = controller.pastTests[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      title: Text(
                        test['schedules']['tests']['title'] ?? 'No Title',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test['schedules']['tests']['description'] ??
                                'No Description',
                          ),
                          const SizedBox(height: 5),
                          Text("Score: ${test['score'] ?? 'N/A'}"),
                          const SizedBox(height: 5),
                          Text("Completed At: ${test['completed_at']}"),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.assignment),
                            tooltip: "View Test Details",
                            onPressed:
                                () => controller.navigateToTestDetails(
                                  test['id'],
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.leaderboard),
                            tooltip: "View Ranking",
                            onPressed:
                                () => controller.navigateToRanking(
                                  test['schedules']['id'],
                                ),
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
