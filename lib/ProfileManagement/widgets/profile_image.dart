import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {

  const ProfileImage({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(180),
        child: Image.asset(
          'assets/images/profilePhoto.jpg', 
          width: 360,
          height: 360,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}