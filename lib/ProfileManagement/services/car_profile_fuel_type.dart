import 'package:flutter/material.dart';

class FuelTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const FuelTypeDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: 'Fuel Type'),
      items: <String>['Petrol', 'Diesel', 'Electric', 'Hybrid']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a fuel type';
        }
        return null;
      },
    );
  }
}