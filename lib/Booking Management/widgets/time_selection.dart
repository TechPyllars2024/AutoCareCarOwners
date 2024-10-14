import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class TimePickerDisplay extends StatefulWidget {
  final TimeOfDay initialTime;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final TextStyle textStyle;
  final Function(TimeOfDay) onTimeSelected;
  final Map<String, int> availableSlots;
  final int standardBookingsPerHour;

  const TimePickerDisplay({
    super.key,
    required this.initialTime,
    required this.startTime,
    required this.endTime,
    required this.onTimeSelected,
    required this.availableSlots,
    this.textStyle = const TextStyle(fontSize: 20),
    required this.standardBookingsPerHour,
  });

  @override
  State<TimePickerDisplay> createState() => _TimePickerDisplayState();
}

class _TimePickerDisplayState extends State<TimePickerDisplay> {
  late TimeOfDay _timeOfDay;
  final Logger logger = Logger();


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
    final int hour =
    timeOfDay.hourOfPeriod == 0 && timeOfDay.period == DayPeriod.pm
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
          availableSlots: widget.availableSlots,
          standardBookingsPerHour: widget.standardBookingsPerHour,
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
      widget.onTimeSelected(selectedTime);
    }
  }

  TimeOfDay _parseTimeSlot(String timeSlot) {
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
  final Map<String, int> availableSlots;
  final int standardBookingsPerHour;

  HourlyTimePicker({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.onTimeSelected,
    required this.availableSlots,
    required this.standardBookingsPerHour,
  });

  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    List<String> timeOptions = _generateTimeOptions(startTime, endTime);

    logger.i('Available Slots Map: $availableSlots');

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
                String timeSlot = timeOptions[index];

                // Get the bookings left for this time slot
                String startTimeKey = timeSlot.split(' - ')[0];
                String formattedKey = _convertTimeToKeyFormat(startTimeKey);
                int bookingsLeft = int.tryParse(_getNormalizedAvailableSlots(formattedKey)?.toString() ?? standardBookingsPerHour.toString()) ?? standardBookingsPerHour;

                // Disable the time slot if no bookings are left
                bool isSlotAvailable = bookingsLeft > 0;

                return GestureDetector(
                  onTap: isSlotAvailable ? () { onTimeSelected(timeSlot); } : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _formatTimeWithBookings(timeSlot),
                      style: TextStyle(
                        fontSize: 18,
                        color: isSlotAvailable ? Colors.black : Colors.red,),
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

    while (current.hour < end.hour ||
        (current.hour == end.hour && current.minute < end.minute)) {
      // Create the next time slot
      String timeSlot = '${_formatTime(current)} - ${_formatTime(TimeOfDay(hour: current.hour + 1, minute: 0))}';
      options.add(timeSlot);
      current = TimeOfDay(hour: current.hour + 1, minute: 0);
    }
    return options;
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final int hour =
    timeOfDay.hourOfPeriod == 0 && timeOfDay.period == DayPeriod.pm
        ? 12
        : timeOfDay.hourOfPeriod;
    final String period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    final String minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatTimeWithBookings(String timeSlot) {
    String startTimeKey = timeSlot.split(' - ')[0]; // Get the start time from the timeSlot

    // Normalize the startTimeKey by replacing non-breaking spaces with regular spaces
    String formattedKey = _convertTimeToKeyFormat(startTimeKey);

    // Debugging: Print keys for verification
    logger.i('Time slot is: $timeSlot');
    logger.i('Formatted Key: $formattedKey');
    logger.i('Available Slots Keys: $availableSlots');
    logger.i('Booking Per Hour: $standardBookingsPerHour');

    // Fetch the available slots, normalizing both formattedKey and availableSlots keys
    String bookingsLeft = _getNormalizedAvailableSlots(formattedKey)?.toString() ?? standardBookingsPerHour.toString();

    return '$timeSlot | Bookings Left: $bookingsLeft';
  }

  String _convertTimeToKeyFormat(String time) {
    // Normalize the time string by replacing non-breaking spaces with regular spaces
    List<String> parts = time.replaceAll('\u202F', ' ').replaceAll('\u00A0', ' ').split(' ');
    String timeOfDay = parts[0]; // "hour:minute"
    String period = parts[1]; // "AM/PM"
    return '$timeOfDay $period'; // e.g., "5:00 AM"
  }

// Normalize the keys in availableSlots by replacing non-breaking spaces and matching formats
  String? _getNormalizedAvailableSlots(String formattedKey) {
    for (String key in availableSlots.keys) {
      // Normalize the key by replacing non-breaking spaces and regularizing spaces
      String normalizedKey = key.replaceAll('\u202F', ' ').replaceAll('\u00A0', ' ');
      if (normalizedKey == formattedKey) {
        return availableSlots[key].toString();
      }
    }
    return null; // Return null if no match found
  }
}


