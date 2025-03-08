import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionTextWidget extends StatelessWidget {
  const QuestionTextWidget({
    super.key,
    required this.controller,
    required this.question,
  });

  final GetxController controller; // Make it dynamic
  final Map<String, dynamic> question;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      int currentIndex =
          (controller as dynamic)
              .currentQuestionIndex
              .value; // Use dynamic casting

      return Text(
        "Q${currentIndex + 1}: ${question['question_text']}",
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
      );
    });
  }
}
