import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T initialValue;
  final ValueChanged<T?> onChanged;
  final Icon icon;
  final Color dropdownColor;
  final Color underlineColor;
  final Color textColor;

  const CustomDropdown({
    Key? key,
    required this.items,
    required this.initialValue,
    required this.onChanged,
    this.icon = const Icon(Icons.arrow_drop_down_sharp),
    this.dropdownColor = Colors.grey,
    this.underlineColor = Colors.grey,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  _CustomDropdownState<T> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  late T dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: dropdownValue,
      icon: widget.icon,
      elevation: 16,
      style: TextStyle(color: widget.textColor, fontSize: 15),
      underline: Container(
        height: 2,
        color: widget.underlineColor,
      ),
      onChanged: (T? value) {
        setState(() {
          dropdownValue = value!;
        });
        widget.onChanged(value);
      },
      items: widget.items.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem<T>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
    );
  }
}
