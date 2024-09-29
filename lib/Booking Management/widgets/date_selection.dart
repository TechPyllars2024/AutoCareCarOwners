import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for getting weekday names

class DatePickerDisplay extends StatefulWidget {
  final DateTime initialDate;
  final TextStyle textStyle;
  final Function(DateTime) onDateSelected;
  final List<String> allowedDaysOfWeek;

  const DatePickerDisplay({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.allowedDaysOfWeek,
    this.textStyle = const TextStyle(fontSize: 20),
  });

  @override
  State<DatePickerDisplay> createState() => _DatePickerDisplayState();
}

class _DatePickerDisplayState extends State<DatePickerDisplay> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectDate,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatDate(_selectedDate),
            style: widget.textStyle,
          ),
        ],
      ),
    );
  }

  // Function to format the date as DD/MM/YYYY
  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  // Date Picker logic with restriction to only allowed days
  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime sixMonthsLater = DateTime(now.year, now.month + 6, now.day);

    // Check if the current selected date is valid
    String selectedDayName = DateFormat('EEEE').format(_selectedDate);
    if (!widget.allowedDaysOfWeek.contains(selectedDayName)) {
      // If the current selected date is not allowed, set to the first allowed day
      DateTime adjustedDate = now;
      while (!widget.allowedDaysOfWeek.contains(DateFormat('EEEE').format(adjustedDate))) {
        adjustedDate = adjustedDate.add(const Duration(days: 1)); // Move to next day
      }
      _selectedDate = adjustedDate; // Update to the first valid date
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: sixMonthsLater,
      selectableDayPredicate: (DateTime day) {
        String dayName = DateFormat('EEEE').format(day);
        return widget.allowedDaysOfWeek.contains(dayName);
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateSelected(_selectedDate);
    }
  }
}
