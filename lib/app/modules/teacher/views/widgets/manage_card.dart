import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showLeadingIcon; // New flag to control the leading icon

  const ManageCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.showLeadingIcon = false, // Default to false for flexibility
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        leading:
            showLeadingIcon
                ? IconButton(
                  icon: const Icon(Icons.list, color: Colors.green),
                  tooltip: "Manage Questions",
                  onPressed: onTap,
                )
                : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
