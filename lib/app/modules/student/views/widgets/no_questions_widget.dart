import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoQuestionsWidget extends StatelessWidget {
  const NoQuestionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No questions available",
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
