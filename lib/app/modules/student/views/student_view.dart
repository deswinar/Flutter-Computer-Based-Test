import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/student_controller.dart';

class StudentView extends GetView<StudentController> {
  const StudentView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudentView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'StudentView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
