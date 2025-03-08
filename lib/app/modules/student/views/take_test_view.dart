import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/take_test_controller.dart';
import 'widgets/no_questions_widget.dart';
import 'widgets/question_text_widget.dart';

class TakeTestView extends StatelessWidget {
  final TakeTestController controller = Get.put(TakeTestController());

  TakeTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              controller.test['title'] ?? 'Test',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Obx(() => _buildCountdownTimer()), // ⏳ Add Countdown Timer
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildTestContent()),
          _buildFinishTestButton(), // Always visible at the bottom
        ],
      ),
    );
  }

  /// **Main Test Content**
  Widget _buildTestContent() {
    return Obx(() {
      if (controller.questions.isEmpty) {
        return NoQuestionsWidget();
      }

      var question =
          controller.questions[controller.currentQuestionIndex.value];

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestionNavigation(),
            const SizedBox(height: 16),
            _buildProgressIndicator(),
            const SizedBox(height: 16),
            QuestionTextWidget(controller: controller, question: question),
            const SizedBox(height: 16),
            _buildOptionsList(question),
          ],
        ),
      );
    });
  }

  /// **Finish Test Button (Always Visible)**
  Widget _buildFinishTestButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        child: ElevatedButton(
          onPressed:
              controller.isSubmitting.value ? null : _showFinishTestDialog,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              controller.isSubmitting.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Finish Test"),
        ),
      ),
    );
  }

  /// **Show confirmation dialog before finishing the test**
  void _showFinishTestDialog() {
    Get.defaultDialog(
      title: "Finish Test",
      middleText:
          "Are you sure you want to submit your test? You cannot change your answers after submitting.",
      textCancel: "Cancel",
      textConfirm: "Submit",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.finishTest(); // Proceed with finishing the test
      },
    );
  }

  /// **Horizontal List of Question Numbers**
  Widget _buildQuestionNavigation() {
    return Obx(() {
      return SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.questions.length,
          itemBuilder: (context, index) {
            bool isSelected = index == controller.currentQuestionIndex.value;
            return GestureDetector(
              onTap: () {
                controller.loadAnswerForQuestion(index);
              },
              child: Container(
                width: 40,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blueAccent : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// **Progress Indicator**
  Widget _buildProgressIndicator() {
    return Obx(() {
      return Text(
        "Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}",
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      );
    });
  }

  /// **Options List (Radio Buttons)**
  Widget _buildOptionsList(Map<String, dynamic> question) {
    return Expanded(
      child: ListView.builder(
        itemCount: (question['options'] as List).length,
        itemBuilder: (context, index) {
          return Obx(
            () => Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: RadioListTile<int>(
                title: Text(
                  question['options'][index],
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                value: index,
                groupValue: controller.selectedAnswer.value,
                onChanged: (val) {
                  controller.saveAnswer(val!);
                },
                activeColor: Colors.blueAccent,
              ),
            ),
          );
        },
      ),
    );
  }

  /// **Countdown Timer Widget**
  Widget _buildCountdownTimer() {
    return Text(
      controller.remainingTime.value,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _getTimerColor(), // Change color dynamically
      ),
    );
  }

  /// **Change Timer Color When Time is Low**
  Color _getTimerColor() {
    if (controller.remainingTime.value.startsWith("00:")) {
      return Colors.red; // Less than 1 hour → RED
    } else if (controller.remainingTime.value.startsWith("01:")) {
      return Colors.orange; // Less than 2 hours → ORANGE
    }
    return Colors.green; // Normal → GREEN
  }
}
