import 'package:flutter/material.dart';

class ColorDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const ColorDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(labelText: 'Color'),
      items: <String>['Red', 
                      'Black', 
                      'White', 
                      'Green', 
                      'Silver', 
                      'Yellow', 
                      'Beige', 
                      'Blue',
                      'Brown',
                      'Gold',
                      'Grey',
                      'Orange',
                      'Pink',
                      'Purple',
                      'Tan']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a color';
        }
        return null;
      },
    );
  }
}