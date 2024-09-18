import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileImage extends StatefulWidget {
  const EditProfileImage({super.key, this.child});

  final Widget? child;

  @override
  State<EditProfileImage> createState() => _EditProfileImageState();
}

class _EditProfileImageState extends State<EditProfileImage> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircleAvatar(
          radius: 150,
          backgroundColor: Colors.white,
          backgroundImage: _image != null ? FileImage(_image!) : null,
          child: _image == null
              ? const Icon(Icons.person, color: Colors.black, size: 150)
              : null,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.gallery),
          child: const Text('Upload Photo', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}