import 'dart:io';
import 'package:autocare_carowners/Booking%20Management/widgets/button.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../Authentication/screens/onboardingPage3.dart';
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
  String? phoneErrorMessage;
  String? firstNameErrorMessage;
  String? lastNameErrorMessage;

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
    // Validate inputs
    if (validatePhoneNumber(phoneNumberController.text) != null ||
        validateName(firstNameController.text) != null ||
        validateName(lastNameController.text) != null) {
      return; // Stop saving if validation fails
    }

    setState(() {
      _isLoading = true;
    });

    // Upload the image if selected
    if (_image != null) {
      final downloadUrl = await _profileService.uploadProfileImage(_image!, widget.currentUser.uid);
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

    // Check if this is the first time saving
    bool isFirstTime = widget.currentUser.firstName.isEmpty &&
        widget.currentUser.lastName.isEmpty &&
        widget.currentUser.phoneNumber.isEmpty;

    // Save profile using the service
    await _profileService.saveUserProfile(updatedProfile);

    // Redirect based on whether it's the first time or just an edit
    if (isFirstTime) {
      // First time: Navigate to next page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboardingpage3()),
      );
    } else {
      // Editing: Pop the current page and pass the updated profile back
      Navigator.pop(context, updatedProfile);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Your phone number validation function
  String? validatePhoneNumber(String phoneNumber) {
    // Regular expression for Philippine phone number validation
    final phoneRegExp = RegExp(r'^(09\d{9})$|^(\+639\d{9})$');

    // Check if the number matches the regex
    if (!phoneRegExp.hasMatch(phoneNumber)) {
      return 'Please enter a valid Philippine phone number';
    }

    return null; // Return null if valid
  }

  // Name validation function
  String? validateName(String name) {
    final nameRegExp = RegExp(r"^[A-Za-z\s]{2,50}$");
    if (!nameRegExp.hasMatch(name)) {
      return 'Please enter a valid name';
    }
    return null;
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
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.orange.shade900), // Border color when focused
                  ),
                  hintText: 'First Name',
                  contentPadding: const EdgeInsets.all(10),
                  errorText: firstNameErrorMessage, // Display name validation error
                ),
                inputFormatters: [
                  CapitalizeEachWordFormatter(),
                ],
                onChanged: (value) {
                  setState(() {
                    firstNameErrorMessage = validateName(value);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextField(
                controller: lastNameController,
                decoration:  InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.orange.shade900),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.orange.shade900), // Border color when focused
                  ),
                  hintText: 'Last Name',
                  contentPadding: const EdgeInsets.all(10),
                  errorText: lastNameErrorMessage,
                ),
                inputFormatters: [
                  CapitalizeEachWordFormatter(),
                ],
                onChanged: (value) {
                  setState(() {
                    lastNameErrorMessage = validateName(value);
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(color: Colors.orange.shade900),
                  ),
                  hintText: 'Phone Number',
                  contentPadding: const EdgeInsets.all(10),
                  errorText: phoneErrorMessage, // Display phone validation error
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                onChanged: (value) {
                  setState(() {
                    phoneErrorMessage = validatePhoneNumber(value);
                  });
                },
              ),
            ),

            const SizedBox(height: 20),
            WideButtons(
              onTap: _saveProfile,
              text: "Save",
            ),
          ],
        ),
      ),
    );
  }
}
