import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_pages.dart';
import '../controllers/teacher_controller.dart';

class TeacherDashboardView extends StatelessWidget {
  final TeacherController controller = Get.find<TeacherController>();

  TeacherDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Teacher Dashboard",
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
          await controller.fetchDashboardData();
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
                  "Welcome, ${controller.teacherName.value}!",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Quick Stats Section
              Obx(
                () =>
                    controller.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildStatCard(
                                title: "Tests Created",
                                value: controller.testCount.value.toString(),
                                icon: Icons.assignment,
                                color: Colors.blue,
                              ),
                              _buildStatCard(
                                title: "Questions Created",
                                value:
                                    controller.questionCount.value.toString(),
                                icon: Icons.help_outline,
                                color: Colors.orange,
                              ),
                              _buildStatCard(
                                title:
                                    "On-going Schedule", // Replaced "Students" with "On-going Schedule"
                                value:
                                    controller.ongoingScheduleCount.value
                                        .toString(),
                                icon: Icons.schedule,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
              ),
              const SizedBox(height: 20),

              // Navigation Buttons
              _buildNavigationButton(
                title: "Manage Tests",
                icon: Icons.assignment,
                onTap: () => Get.toNamed(Routes.MANAGE_TESTS),
              ),
              const SizedBox(height: 10),
              _buildNavigationButton(
                title: "Manage Schedules",
                icon: Icons.schedule,
                onTap: () => Get.toNamed(Routes.MANAGE_SCHEDULES),
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
                        : controller.recentActivity.isEmpty
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
                              controller.recentActivity
                                  .map(
                                    (activity) => ListTile(
                                      leading: const Icon(Icons.history),
                                      title: Text(
                                        activity,
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 5),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
