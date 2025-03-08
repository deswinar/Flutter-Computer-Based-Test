import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_pages.dart';
import '../controllers/student_controller.dart';
import 'widgets/navigation_button.dart';
import 'widgets/stat_card.dart';

class StudentDashboardView extends StatelessWidget {
  final StudentController controller = Get.find<StudentController>();

  StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Student Dashboard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.defaultDialog(
                title: "Logout",
                middleText: "Are you sure you want to logout?",
                textConfirm: "Yes",
                textCancel: "No",
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back(); // Close the dialog
                  controller.logout(); // Perform logout
                },
              );
            },
            tooltip: "Logout",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchStudentData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Obx(
                () => Text(
                  "Hello, ${controller.studentName.value}!",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Quick Stats
              Obx(
                () =>
                    controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StatCard(
                              title: "Total Tests",
                              value: controller.testCount.value.toString(),
                              icon: Icons.assignment,
                              color: Colors.blue,
                            ),
                            StatCard(
                              title: "Upcoming Schedules",
                              value:
                                  controller.upcomingScheduleCount.value
                                      .toString(),
                              icon: Icons.schedule,
                              color: Colors.orange,
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 20),

              // Navigation Buttons
              NavigationButton(
                title: "Available Tests",
                icon: Icons.list,
                onTap: () => Get.toNamed(Routes.AVAILABLE_TESTS),
              ),
              const SizedBox(height: 10),
              NavigationButton(
                title: "Upcoming Schedules",
                icon: Icons.event,
                onTap: () => Get.toNamed(Routes.UPCOMING_SCHEDULES),
              ),
              const SizedBox(height: 10),
              NavigationButton(
                title: "Past Tests",
                icon: Icons.history,
                onTap: () => Get.toNamed(Routes.PAST_TESTS),
              ),
              const SizedBox(height: 20),

              // Recent Activity
              Text(
                "Recent Activity",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () =>
                    controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : controller.recentTests.isEmpty
                        ? Center(
                          child: Text(
                            "No recent activity",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                        : Column(
                          children:
                              controller.recentTests
                                  .map(
                                    (test) => ListTile(
                                      leading: const Icon(Icons.history),
                                      title: Text(
                                        test,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
