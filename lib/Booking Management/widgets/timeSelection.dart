import 'package:flutter/material.dart';

class TimePickerDisplay extends StatefulWidget {
  final TimeOfDay initialTime;
  final TimeOfDay startTime; // Opening time
  final TimeOfDay endTime;   // Closing time
  final TextStyle textStyle;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerDisplay({
    super.key,
    required this.initialTime,
    required this.startTime,
    required this.endTime,
    required this.onTimeSelected,
    this.textStyle = const TextStyle(fontSize: 20),
  });

  @override
  State<TimePickerDisplay> createState() => _TimePickerDisplayState();
}

class _TimePickerDisplayState extends State<TimePickerDisplay> {
  late TimeOfDay _timeOfDay;

  @override
  void initState() {
    super.initState();
    _timeOfDay = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _selectTime,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _formatTime(_timeOfDay),
            style: widget.textStyle,
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final int hour = timeOfDay.hourOfPeriod == 0 && timeOfDay.period == DayPeriod.pm
        ? 12
        : timeOfDay.hourOfPeriod;
    final String period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: _timeOfDay,
      context: context,
    );

    if (pickedTime != null) {
      // Check if the selected time is within the operating hours
      if (_isTimeWithinOperatingHours(pickedTime, widget.startTime, widget.endTime)) {
        setState(() {
          _timeOfDay = pickedTime;
        });
        widget.onTimeSelected(pickedTime); // Notify the parent of the selected time
      } else {
        // Show a message if the selected time is outside operating hours
        _showErrorDialog(
          context,
          "Invalid Time",
          "Please select a time between ${_formatTime(widget.startTime)} and ${_formatTime(widget.endTime)}.",
        );
      }
    }
  }

  bool _isTimeWithinOperatingHours(TimeOfDay selected, TimeOfDay start, TimeOfDay end) {
    // Convert TimeOfDay to minutes since midnight for easier comparison
    int selectedMinutes = selected.hour * 60 + selected.minute;
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    return selectedMinutes >= startMinutes && selectedMinutes <= endMinutes;
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
