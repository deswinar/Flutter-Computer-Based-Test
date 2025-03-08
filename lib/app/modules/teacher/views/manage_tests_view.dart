import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/test_controller.dart';
import '../controllers/question_controller.dart';
import 'manage_questions_view.dart';
import 'widgets/manage_card.dart';
import 'widgets/test_dialogs.dart';
import 'package:intl/intl.dart';

class ManageTestsView extends StatelessWidget {
  final TestController controller = Get.find<TestController>();
  final QuestionController questionController = Get.find<QuestionController>();

  ManageTestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    // Scroll listener for pagination
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          controller.hasMoreData.value &&
          !controller.isLoadingMore.value) {
        controller.loadMoreTests();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Get.back()),
        title: Text(
          "Manage Tests",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: controller.clearFilters,
            child: Text(
              "Clear Filters",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: controller.setSearchQuery,
                        decoration: InputDecoration(
                          labelText: "Search by title",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: controller.clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text("Clear"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Date Range Filter
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            controller.setDateRange(picked.start, picked.end);
                          }
                        },
                        child: Obx(() {
                          String text =
                              controller.startDate.value != null &&
                                      controller.endDate.value != null
                                  ? "${DateFormat.yMMMd().format(controller.startDate.value!)} - ${DateFormat.yMMMd().format(controller.endDate.value!)}"
                                  : "Select Date Range";
                          return InputDecorator(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(text),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Sorting Dropdown
                    Obx(
                      () => DropdownButton<String>(
                        value: controller.sortBy.value,
                        items:
                            [
                              {'label': 'Title', 'value': 'title'},
                              {'label': 'Duration', 'value': 'duration'},
                              {'label': 'Date Created', 'value': 'created_at'},
                            ].map((item) {
                              return DropdownMenuItem<String>(
                                value: item['value'],
                                child: Text(item['label']!),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSorting(value);
                          }
                        },
                      ),
                    ),
                    // Sorting Order Toggle
                    IconButton(
                      icon: Obx(
                        () => Icon(
                          controller.ascending.value
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                      ),
                      onPressed: () {
                        controller.setSorting(
                          controller.sortBy.value,
                          asc: !controller.ascending.value,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.tests.isEmpty) {
                return Center(
                  child: Text(
                    "No tests available.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.tests.length + 1,
                itemBuilder: (context, index) {
                  if (index == controller.tests.length) {
                    return controller.hasMoreData.value
                        ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : const SizedBox.shrink();
                  }

                  final test = controller.tests[index];
                  return ManageCard(
                    title: test['title'],
                    subtitle:
                        "${test['description']}\nDuration: ${test['duration']} minutes",
                    onTap: () {
                      questionController.setTest(test);
                      Get.to(() => ManageQuestionsView());
                    },
                    onEdit: () => showEditTestDialog(controller, test),
                    onDelete:
                        () => showConfirmDeleteDialog(controller, test['id']),
                    showLeadingIcon: true,
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddTestDialog(controller),
        icon: const Icon(Icons.add),
        label: Text(
          "Add Test",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
