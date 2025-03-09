import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadUserProfile();

    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(controller.user.value.email, style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),

              Text("Name", style: TextStyle(fontSize: 14, color: Colors.grey)),
              TextFormField(
                initialValue: controller.user.value.name,
                onFieldSubmitted: (value) {
                  controller.updateUserName(value);
                },
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              Text("Role", style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                controller.user.value.role.toUpperCase(),
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),

              Text(
                "Joined on",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                controller.user.value.createdAt.toString().split(" ")[0],
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        );
      }),
    );
  }
}
