import 'package:flutter/material.dart';

class TextFieldPassword extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData? icon;
  final TextInputType textInputType;

  const TextFieldPassword({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    this.icon,
    required this.textInputType,
  });

  @override
  _TextFieldPasswordState createState() => _TextFieldPasswordState();
}

class _TextFieldPasswordState extends State<TextFieldPassword> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: const TextStyle(fontSize: 20),
      controller: widget.textEditingController,
      obscureText: widget.isPass && !_isPasswordVisible, // Toggle password visibility
      keyboardType: widget.textInputType,
      decoration: InputDecoration(
        labelText: widget.hintText,
        prefixIcon: widget.icon != null ? Icon(widget.icon, color: Colors.black54, size: 24) : null,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 77, 76, 76)),
        suffixIcon: widget.isPass
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:  BorderSide(color: Colors.black26, width: 3),
        ),
        focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black26, width: 3),
        ),
      ),
    );
  }
}