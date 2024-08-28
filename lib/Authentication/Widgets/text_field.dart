import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData? icon;
  final TextInputType textInputType;
  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    this.icon,
    required this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextField(
          style: const TextStyle(fontSize: 20),
          controller: textEditingController,
          decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black45, size: 18),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: const Color(0xFFedf0f8),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              )),
          keyboardType: textInputType,
          obscureText: isPass),
    );
  }
}
