import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData? icon;
  final TextInputType textInputType;
  final Widget? child;

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    this.icon,
    required this.textInputType,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 20),
      controller: textEditingController,
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.black54, size: 24)
            : null,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 77, 76, 76)),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black26, width: 3),
        ),
        focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black26, width: 3),
        ),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
