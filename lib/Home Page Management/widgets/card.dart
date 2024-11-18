import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  const CardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * 0.3,
      height: screenHeight * 0.2,
      child: Card(
        color: Colors.white,
        elevation: 8,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),

        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 50),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, ), textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }}
