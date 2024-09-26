import 'package:flutter/material.dart';

class WideButtons extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  final double padding;

  const WideButtons({
    super.key,
    required this.onTap,
    required this.text,
    this.color = Colors.orange,
    this.padding = 25.0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.black26,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
          decoration: ShapeDecoration(
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            color: Colors.orange.shade900,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize:16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
