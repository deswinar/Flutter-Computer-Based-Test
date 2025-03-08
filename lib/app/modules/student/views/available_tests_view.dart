import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/available_tests_controller.dart';

class AvailableTestsView extends StatelessWidget {
  final AvailableTestsController controller = Get.put(
    AvailableTestsController(),
  );

  AvailableTestsView({super.key});

  void _showTestDialog(BuildContext context, Map<String, dynamic> test) {
    final bool isCompleted = test['student_test']?['status'] == 'completed';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(test['tests']['title'] ?? 'Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(test['tests']['description'] ?? 'No Description'),
              SizedBox(height: 10),
              Text("Duration: ${test['tests']['duration']} minutes"),
              SizedBox(height: 10),
              Text("Questions: ${test['question_count']}"),
              SizedBox(height: 10),
              Text("Start: ${test['start_time']}"),
              Text("End: ${test['end_time']}"),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
            if (!isCompleted)
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close the dialog
                  controller.startTest(test);
                },
                child: Text("Start Test"),
              )
            else
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                ),
                child: Text("Completed"),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Tests")),
      body: Column(
        children: [
          // Filter & Sort Row
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Filter Dropdown
                DropdownButton<String>(
                  value: controller.selectedFilter.value,
                  items:
                      ['All', 'Completed', 'Not Completed']
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
                      ['Start Time', 'Question Count']
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

          // Test List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.filteredTests.isEmpty) {
                return Center(child: Text("No available tests for today"));
              }

              return ListView.builder(
                itemCount: controller.filteredTests.length,
                itemBuilder: (context, index) {
                  final test = controller.filteredTests[index];
                  final bool isCompleted = test['status'] == 'completed';

                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(test['tests']['title'] ?? 'No Title'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test['tests']['description'] ?? 'No Description',
                          ),
                          SizedBox(height: 5),
                          Text("Questions: ${test['question_count']}"),
                          SizedBox(height: 5),
                          Text("Start: ${test['start_time']}"),
                          Text("End: ${test['end_time']}"),
                        ],
                      ),
                      trailing:
                          isCompleted
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : IconButton(
                                icon: Icon(
                                  Icons.play_arrow,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showTestDialog(context, test),
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
