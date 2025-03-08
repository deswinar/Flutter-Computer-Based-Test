import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return RouteSettings(
        name: "/login",
      ); // Redirect to login if not authenticated
    }
    return null; // Allow navigation if user is logged in
  }
}
