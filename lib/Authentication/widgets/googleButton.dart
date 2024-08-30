import 'package:flutter/material.dart';

class GoogleButton extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;

  const GoogleButton({
    Key? key,
    required this.textEditingController,
    required this.isPass,
    required this.hintText,
  }) : super(key: key);

  @override
  _GoogleButtonState createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<GoogleButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Google sign-in logic
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shadowColor: Colors.black,
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24, 
            height: 24, 
            child: Image.asset('lib/Authentication/assets/images/icons/google.png'),
          ),
          const SizedBox(width: 8), // Space between image and text
          Text(widget.hintText, style: const TextStyle(color: Colors.black, fontSize: 16)),
        ],
      ),
    );
  }
}