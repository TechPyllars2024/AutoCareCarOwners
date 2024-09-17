import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_owner_address_model.dart';
import '../models/car_owner_profile_model.dart';

class CarOwnerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user profile from the 'car owner profile' collection
  Future<CarOwnerProfileModel?> fetchUserProfile(String uid) async {
    try {
      final docSnapshot = await _firestore
          .collection('car_owner_profiles')
          .doc(uid)
          .get();

      if (docSnapshot.exists) {
        return CarOwnerProfileModel.fromDocument(
            docSnapshot.data()!, uid);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  // Create or update a car owner profile
  Future<void> saveUserProfile(CarOwnerProfileModel profile) async {
    try {
      await _firestore
          .collection('car_owner_profiles')
          .doc(profile.uid)
          .set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Fetch user email from Firestore (as a separate collection or part of the profile)
  Future<String?> fetchUserEmail(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['email'];
      }
    } catch (e) {
      print('Error fetching user email: $e');
    }
    return null;
  }

  // Stream to fetch default address
  Stream<CarOwnerAddressModel?> getDefaultAddress(String uid) {
    return _firestore
        .collection('car_owner_profiles')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return CarOwnerAddressModel.fromDocument(snapshot.data()!);
      }
      return null;
    });
  }
}
