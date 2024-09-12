import 'package:flutter/material.dart';

class TransmissionModel {
  final String type;

  TransmissionModel(this.type);
}

class TransmissionDropdown extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const TransmissionDropdown({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TransmissionDropdownState createState() => _TransmissionDropdownState();
}

class _TransmissionDropdownState extends State<TransmissionDropdown> {
  late String selectedTransmission;
  final List<TransmissionModel> transmissions = [
    TransmissionModel('Automatic'),
    TransmissionModel('Manual'),
  ];

  @override
  void initState() {
    super.initState();
    selectedTransmission = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedTransmission,
      decoration: const InputDecoration(labelText: 'Transmission Type'),
      items: transmissions
          .map((transmission) => DropdownMenuItem(
                value: transmission.type,
                child: Text(transmission.type),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedTransmission = newValue!;
        });
        widget.onChanged(newValue!);
      },
    );
  }
}
