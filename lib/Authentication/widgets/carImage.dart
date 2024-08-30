import 'package:flutter/material.dart';

class CarImageWidget extends StatelessWidget {
  final String imagePath;

  const CarImageWidget({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

@override
Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      height: 180,
    );
  }
}