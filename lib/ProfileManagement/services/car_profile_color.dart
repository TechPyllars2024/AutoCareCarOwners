import 'package:flutter/material.dart';

class ColorModel {
  final String name;

  ColorModel(this.name);
}

class ColorDropdown extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const ColorDropdown({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _ColorDropdownState createState() => _ColorDropdownState();
}

class _ColorDropdownState extends State<ColorDropdown> {
  late String selectedColor;
  final List<ColorModel> colors = [
    ColorModel('Red'),
    ColorModel('Black'),
    ColorModel('White'),
    ColorModel('Green'),
    ColorModel('Silver'),
    ColorModel('Yellow'),
    ColorModel('Beige'),
    ColorModel('Blue'),
    ColorModel('Brown'),
    ColorModel('Gold'),
    ColorModel('Grey'),
    ColorModel('Orange'),
    ColorModel('Pink'),
    ColorModel('Purple'),
    ColorModel('Tan'),
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedColor,
      decoration: const InputDecoration(labelText: 'Color'),
      items: colors
          .map((color) => DropdownMenuItem(
                value: color.name,
                child: Text(color.name),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          selectedColor = newValue!;
        });
        widget.onChanged(newValue!);
      },
    );
  }
}