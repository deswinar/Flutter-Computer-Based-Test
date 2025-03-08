import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RoleMiddleware extends GetMiddleware {
  final String requiredRole;
  final box = GetStorage();

  RoleMiddleware(this.requiredRole);

  @override
  RouteSettings? redirect(String? route) {
    String? userRole = box.read("userRole");

    if (userRole == null) {
      return RouteSettings(
        name: "/login",
      ); // Redirect to login if not authenticated
    }

    if (userRole != requiredRole) {
      return RouteSettings(
        name: "/unauthorized",
      ); // Redirect to an unauthorized page
    }

    return null; // Allow access if role matches
  }
}
