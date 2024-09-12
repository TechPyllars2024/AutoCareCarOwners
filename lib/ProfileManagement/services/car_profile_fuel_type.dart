import 'package:flutter/material.dart';

class FuelModel {
  final String type;

  FuelModel(this.type);
}

class FuelDropdown extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const FuelDropdown({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _FuelDropdownState createState() => _FuelDropdownState();
}

class _FuelDropdownState extends State<FuelDropdown> {
  late String selectedFuel;
  final List<FuelModel> fuels = [
    FuelModel('Petrol'),
    FuelModel('Diesel'),
    FuelModel('Electric'),
    FuelModel('Electric'),
  ];

  @override
  void initState() {
    super.initState();
    selectedFuel = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedFuel,
      decoration: const InputDecoration(labelText: 'Fuel Type'),
      items: fuels
          .map((fuel) => DropdownMenuItem(
                value: fuel.type,
                child: Text(fuel.type),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedFuel = newValue!;
        });
        widget.onChanged(newValue!);
      },
    );
  }
}