import 'dart:io';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CarOwnerEditProfile extends StatefulWidget {
  final CarOwnerProfileModel currentUser;

  final Widget? child;

  const CarOwnerEditProfile({super.key, required this.currentUser, this.child});

  @override
  State<CarOwnerEditProfile> createState() => _CarOwnerEditProfileState();
}

class _CarOwnerEditProfileState extends State<CarOwnerEditProfile> {
  late TextEditingController nameController;
  late TextEditingController profileImageController;
  File? _image;
  bool _isLoading = false;

  CarOwnerProfileModel? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    nameController = TextEditingController(text: currentUser?.name ?? '');
    profileImageController =
        TextEditingController(text: currentUser?.profileImage ?? '');
  }

  Future<void> _pickImage(ImageSource gallery) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        profileImageController.text = pickedFile.path;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(currentUser!.uid);
      await storageRef.putFile(_image!);
      final downloadUrl = await storageRef.getDownloadURL();
      profileImageController.text = downloadUrl;
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });
    await _uploadImage();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // print('Current user email before saving: ${widget.currentUser.email}'); // Debugging line
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final existingEmail = doc.data()?['email'] ?? '';

      final updatedUser = CarOwnerProfileModel(
        uid: user.uid,
        name: nameController.text,
        email: existingEmail,
        profileImage: profileImageController.text,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(updatedUser.toMap());
      Navigator.pop(context, updatedUser);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'EDIT PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
        actions: [
          IconButton(
              onPressed: () => {},
              icon: const Icon(
                Icons.settings,
                size: 30,
              )),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                      radius: 150,
                      backgroundColor: Colors.white,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (profileImageController.text.isNotEmpty
                              ? NetworkImage(profileImageController.text)
                              : null),
                      child:
                          _image == null && profileImageController.text.isEmpty
                              ? const Icon(Icons.person,
                                  size: 150, color: Colors.black)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text('Change Photo',
                        style: TextStyle(color: Colors.black)),
                  ),
                  // Edit name
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Edit name',
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(400, 50),
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: _saveProfile,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}
