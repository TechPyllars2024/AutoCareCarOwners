import 'package:flutter/material.dart';

class DiagnosisField extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DiagnosisField({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        width: screenWidth * 1,
        height: screenHeight * 0.1,
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Container(
                    width: screenWidth * 0.5,
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.35,
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
