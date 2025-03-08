import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationButton extends StatelessWidget {
  const NavigationButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
