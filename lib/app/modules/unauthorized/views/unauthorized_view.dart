import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class UnauthorizedView extends StatelessWidget {
  const UnauthorizedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Unauthorized")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("🚫 You do not have permission to access this page."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.LOGIN),
              child: Text("Go to Login"),
            ),
          ],
        ),
      ),
    );
  }
}
