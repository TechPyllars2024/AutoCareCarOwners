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
      onTap: _showHourlyTimePicker,
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

  Future<void> _showHourlyTimePicker() async {
    final String? pickedTimeSlot = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return HourlyTimePicker(
          startTime: widget.startTime,
          endTime: widget.endTime,
          onTimeSelected: (String selectedTime) {
            Navigator.of(context).pop(selectedTime);
          },
        );
      },
    );

    if (pickedTimeSlot != null) {
      // Parse the start time from the selected time slot
      TimeOfDay selectedTime = _parseTimeSlot(pickedTimeSlot);
      setState(() {
        _timeOfDay = selectedTime;
      });
      widget.onTimeSelected(selectedTime); // Notify the parent of the selected time
    }
  }

  TimeOfDay _parseTimeSlot(String timeSlot) {
    // Extract the start time from the time slot string
    String startTimeStr = timeSlot.split(' - ')[0];
    return _convertStringToTimeOfDay(startTimeStr);
  }

  TimeOfDay _convertStringToTimeOfDay(String timeStr) {
    List<String> parts = timeStr.split(' ');
    String hourMinute = parts[0];
    String period = parts[1];

    int hour = int.parse(hourMinute.split(':')[0]);
    if (period == 'PM' && hour != 12) {
      hour += 12; // Convert PM hours
    } else if (period == 'AM' && hour == 12) {
      hour = 0; // Convert 12 AM to 0 hours
    }
    int minute = int.parse(hourMinute.split(':')[1]);

    return TimeOfDay(hour: hour, minute: minute);
  }
}

class HourlyTimePicker extends StatelessWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(String) onTimeSelected;

  const HourlyTimePicker({
    Key? key,
    required this.startTime,
    required this.endTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> timeOptions = _generateTimeOptions(startTime, endTime);

    return Container(
      padding: const EdgeInsets.all(16),
      height: 300, // Height of the modal
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Time Slot',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: timeOptions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onTimeSelected(timeOptions[index]);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      timeOptions[index],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateTimeOptions(TimeOfDay start, TimeOfDay end) {
    List<String> options = [];
    TimeOfDay current = start;

    while (current.hour < end.hour || (current.hour == end.hour && current.minute < end.minute)) {
      TimeOfDay next = current.minute == 30
          ? TimeOfDay(hour: current.hour + 1, minute: 0)
          : TimeOfDay(hour: current.hour, minute: 30);

      options.add('${_formatTime(current)} - ${_formatTime(next)}');
      current = next;
    }

    return options;
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final int hour = timeOfDay.hourOfPeriod == 0 && timeOfDay.period == DayPeriod.pm
        ? 12
        : timeOfDay.hourOfPeriod;
    final String period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
