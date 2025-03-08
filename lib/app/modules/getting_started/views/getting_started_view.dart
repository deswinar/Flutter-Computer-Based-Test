import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_pages.dart';

class GettingStartedView extends StatelessWidget {
  const GettingStartedView({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double fontSize(double size) {
      return size * (screenWidth / 400);
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            children: [
              const Spacer(), // Push content towards the center
              // Rounded Image
              ClipRRect(
                borderRadius: BorderRadius.circular(20), // Rounded edges
                child: Image.asset(
                  "assets/images/getting-started-top.png",
                  height: screenHeight * 0.3,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: screenHeight * 0.04),

              // App Name
              Text(
                "Welcome to MyApp",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: fontSize(28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenHeight * 0.015),

              // Subtitle
              Text(
                "Join us and start your journey today!",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: fontSize(16),
                    color: Colors.black54,
                  ),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenHeight * 0.05),

              // Login Button
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.LOGIN),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.2,
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Login",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(18),
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Register Button
              OutlinedButton(
                onPressed: () => Get.toNamed(Routes.REGISTER),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.2,
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(color: Colors.blueAccent),
                ),
                child: Text(
                  "Register",
                  style: GoogleFonts.poppins(
                    fontSize: fontSize(18),
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              const Spacer(), // Balance spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
