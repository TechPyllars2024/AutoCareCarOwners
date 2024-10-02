import 'dart:io';
import 'package:autocare_carowners/Booking%20Management/widgets/button.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/profile_service.dart';

class CarOwnerEditProfileScreen extends StatefulWidget {
  final CarOwnerProfileModel currentUser;

  const CarOwnerEditProfileScreen({super.key, required this.currentUser});

  @override
  State<CarOwnerEditProfileScreen> createState() => _CarOwnerEditProfileScreenState();
}

class _CarOwnerEditProfileScreenState extends State<CarOwnerEditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController profileImageController;
  File? _image;
  bool _isLoading = false;
  final CarOwnerProfileService _profileService = CarOwnerProfileService();

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.currentUser.firstName);
    lastNameController = TextEditingController(text: widget.currentUser.lastName);
    phoneNumberController = TextEditingController(text: widget.currentUser.phoneNumber);
    profileImageController =
        TextEditingController(text: widget.currentUser.profileImage);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        profileImageController.text = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Upload the image if selected
    if (_image != null) {
      final downloadUrl = await _profileService.uploadProfileImage(
          _image!, widget.currentUser.uid);
      profileImageController.text = downloadUrl;
    }

    // Create updated profile
    final updatedProfile = CarOwnerProfileModel(
      profileId: widget.currentUser.profileId,
      uid: widget.currentUser.uid,
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      phoneNumber: phoneNumberController.text,
      email: widget.currentUser.email,
      profileImage: profileImageController.text,
    );

    // Save profile using the service
    await _profileService.saveUserProfile(updatedProfile);
    Navigator.pop(context, updatedProfile);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: Colors.white,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (profileImageController.text.isNotEmpty
                              ? NetworkImage(profileImageController.text)
                              : null),
                      child:
                          _image == null && profileImageController.text.isEmpty
                              ? const Icon(Icons.person,
                                  size: 100, color: Colors.black)
                              : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.orange.shade900),
                    ),
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Text('Change Photo',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: TextField(
                      controller: firstNameController,
                      decoration:  InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.orange
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.orange.shade900), // Border color when focused
                        ),

                        hintText: 'First Name',
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: TextField(
                      controller: lastNameController,
                      decoration:  InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.orange.shade900
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.orange.shade900), // Border color when focused
                        ),

                        hintText: 'Last Name',
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: TextField(
                      controller: phoneNumberController,
                      decoration:  InputDecoration(
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.orange
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.orange.shade900), // Border color when focused
                        ),

                        hintText: 'Phone Number',
                        contentPadding: const EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11)
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  WideButtons(
                      onTap: _saveProfile,
                      text: "Save"
                  ),
                ],
              ),
            ),
    );
  }
}
