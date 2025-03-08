import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onDateTimePicked,
  });

  final String label;
  final DateTime? initialValue;
  final Function(DateTime p1) onDateTimePicked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.blue),
      title: Text(label),
      subtitle: Text(
        initialValue != null
            ? DateFormat("yyyy-MM-dd HH:mm").format(initialValue!)
            : "Select Date & Time",
        style: GoogleFonts.poppins(color: Colors.grey[600]),
      ),
      onTap: () async {
        DateTime now = DateTime.now();
        DateTime? pickedDate = await showDatePicker(
          context: Get.context!,
          initialDate: initialValue ?? now,
          firstDate: now,
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: Get.context!,
            initialTime: TimeOfDay.fromDateTime(initialValue ?? now),
          );

          if (pickedTime != null) {
            DateTime finalDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            onDateTimePicked(finalDateTime);
          }
        }
      },
    );
  }
}
