import 'package:flutter/material.dart';

class DatePickerDisplay extends StatefulWidget {
  final DateTime initialDate;
  final TextStyle textStyle;
  final Function(DateTime) onDateSelected;

  const DatePickerDisplay({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
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

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime sixMonthsLater = DateTime(now.year, now.month + 6, now.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now, // Restrict past dates
      lastDate: sixMonthsLater, // Restrict dates to 6 months after today
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateSelected(_selectedDate); // Call the parent callback
    }
  }
}
