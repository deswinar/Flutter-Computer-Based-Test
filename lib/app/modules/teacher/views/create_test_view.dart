import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/test_controller.dart';

class CreateTestView extends StatelessWidget {
  final TestController controller = Get.find<TestController>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  CreateTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Test")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Test Title"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextField(
              controller: durationController,
              decoration: InputDecoration(labelText: "Duration (minutes)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.createTest(
                  titleController.text,
                  descriptionController.text,
                  int.tryParse(durationController.text) ?? 0,
                );
              },
              child: Text("Create Test"),
            ),
          ],
        ),
      ),
    );
  }
}
