import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/test_controller.dart';

void showAddTestDialog(TestController controller) {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();

  Get.defaultDialog(
    title: "Add New Test",
    content: _buildDialogContent(
      titleController,
      descriptionController,
      durationController,
    ),
    textConfirm: "Create",
    textCancel: "Cancel",
    confirmTextColor: Colors.white,
    onConfirm: () {
      if (_validateInputs(
        titleController,
        descriptionController,
        durationController,
      )) {
        controller.createTest(
          titleController.text,
          descriptionController.text,
          int.parse(durationController.text),
        );
        Get.back();
      } else {
        Get.snackbar("Error", "All fields are required");
      }
    },
  );
}

void showEditTestDialog(TestController controller, Map<String, dynamic> test) {
  final titleController = TextEditingController(text: test['title']);
  final descriptionController = TextEditingController(
    text: test['description'],
  );
  final durationController = TextEditingController(
    text: test['duration'].toString(),
  );

  Get.defaultDialog(
    title: "Edit Test",
    content: _buildDialogContent(
      titleController,
      descriptionController,
      durationController,
    ),
    textConfirm: "Save Changes",
    textCancel: "Cancel",
    confirmTextColor: Colors.white,
    onConfirm: () {
      if (_validateInputs(
        titleController,
        descriptionController,
        durationController,
      )) {
        controller.updateTest(
          test['id'],
          titleController.text,
          descriptionController.text,
          int.parse(durationController.text),
        );
        Get.back();
      } else {
        Get.snackbar("Error", "All fields are required");
      }
    },
  );
}

void showConfirmDeleteDialog(TestController controller, String testId) {
  Get.defaultDialog(
    title: "Delete Test",
    middleText: "Are you sure you want to delete this test?",
    textConfirm: "Yes",
    textCancel: "No",
    confirmTextColor: Colors.white,
    onConfirm: () {
      controller.deleteTest(testId);
      Get.back();
    },
  );
}

// Reusable input fields for dialogs
Widget _buildDialogContent(
  TextEditingController title,
  TextEditingController desc,
  TextEditingController duration,
) {
  return Column(
    children: [
      _buildTextField(title, "Test Title"),
      const SizedBox(height: 10),
      _buildTextField(desc, "Test Description"),
      const SizedBox(height: 10),
      _buildTextField(duration, "Duration (minutes)", isNumber: true),
    ],
  );
}

// Input validation function
bool _validateInputs(
  TextEditingController title,
  TextEditingController desc,
  TextEditingController duration,
) {
  return title.text.isNotEmpty &&
      desc.text.isNotEmpty &&
      duration.text.isNotEmpty;
}

// Reusable text field widget
Widget _buildTextField(
  TextEditingController controller,
  String label, {
  bool isNumber = false,
}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
