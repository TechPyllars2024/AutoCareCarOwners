import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/car_owner_address_model.dart';
import '../models/car_owner_profile_model.dart';

class CarOwnerProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    final user = _auth.currentUser;
    return user?.email;
  }

  // Fetch user profile from Firestore or return default profile
  Future<CarOwnerProfileModel?> fetchUserProfile() async {
    final user = _auth.currentUser;
    String profileId = _firestore.collection("car_owner_profile").doc().id;
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
          return CarOwnerProfileModel(
            profileId: profileId,
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            profileImage: '',
          );
        }
      } catch (e) {
        // Handle potential Firestore errors
        return null;
      }
    }
    return null;
  }

  // Fetch user email directly from Firebase Auth
  Future<String?> fetchUserEmail() async {
    final user = _auth.currentUser;
    return user?.email;
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
        // Handle potential Firestore errors
        yield null;
      }
    }
  }
}
