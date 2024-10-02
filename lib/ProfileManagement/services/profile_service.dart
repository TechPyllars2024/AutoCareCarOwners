import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../models/car_owner_address_model.dart';
import '../models/car_owner_profile_model.dart';

class CarOwnerProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final logger = Logger();

  Future<String> uploadProfileImage(File imageFile, String uid) async {
    final storageRef = _storage.ref().child('profile_images/$uid');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  Future<void> saveUserProfile(CarOwnerProfileModel updatedProfile) async {
    await _firestore
        .collection('car_owner_profile')
        .doc(updatedProfile.uid)
        .set(updatedProfile.toMap());
  }

  Future<String?> getUserEmail() async {
    try {
      final user = _auth.currentUser;
      return user?.email;
    } catch (e) {
      logger.i('Error fetching user email: $e');
      return null;
    }
  }

  // Fetch user profile from Firestore or return default profile
  Future<CarOwnerProfileModel?> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore
            .collection('car_owner_profile')
            .doc(user.uid)
            .get();
        final data = doc.data();

        if (data != null) {
          return CarOwnerProfileModel.fromDocument(data, user.uid);
        } else {
          // Return a default profile if no data found
          return CarOwnerProfileModel(
            profileId: _firestore.collection("car_owner_profile").doc().id,
            uid: user.uid,
            firstName: '',
            lastName: '',
            phoneNumber: user.phoneNumber ?? '',
            email: user.email ?? '',
            profileImage: '',
          );
        }
      } catch (e) {
        logger.i('Error fetching user profile: $e');
        return null;
      }
    }
    return null; // Return null if user is not logged in
  }

  // Fetch user email directly from Firebase Auth
  Future<String?> fetchUserEmail() async {
    try {
      final user = _auth.currentUser;
      return user?.email;
    } catch (e) {
      logger.i('Error fetching user email: $e');
      return null;
    }
  }

  // Fetch default address using Firestore streams
  Stream<CarOwnerAddressModel?> getDefaultAddress() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield null;
    } else {
      try {
        await for (final snapshot in _firestore
            .collection('car_owner_profile')
            .doc(user.uid)
            .collection('addresses')
            .where('isDefault', isEqualTo: true)
            .snapshots()) {
          if (snapshot.docs.isNotEmpty) {
            yield CarOwnerAddressModel.fromMap(snapshot.docs.first.data());
          } else {
            yield null; // No default address found
          }
        }
      } catch (e) {
        logger.i('Error fetching default address: $e');
        yield null; // Return null in case of an error
      }
    }
  }
}
