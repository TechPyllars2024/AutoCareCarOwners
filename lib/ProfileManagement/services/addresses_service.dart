import 'package:autocare_carowners/ProfileManagement/models/car_owner_address_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressService {
  late CollectionReference addressCollection;

  AddressService() {
    _initializeFirestore();
  }

  void _initializeFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      addressCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');
    }
  }

  Future<List<CarOwnerAddressModel>> fetchAddresses() async {
    final snapshot = await addressCollection.get();
    return snapshot.docs
      .map((doc) => CarOwnerAddressModel.fromMap(doc.data() as Map<String, dynamic>))
      .toList();
  }

  Future<void> addAddress(CarOwnerAddressModel address) async {
    await addressCollection.add(address.toMap());
  }

  Future<void> editAddress(String docId, CarOwnerAddressModel address) async {
    await addressCollection.doc(docId).update(address.toMap());
  }

  Future<void> deleteAddress(String docId) async {
    await addressCollection.doc(docId).delete();
  }

  Future<void> setDefaultAddress(int index, List<CarOwnerAddressModel> addresses) async {
    // Update local state immediately
    for (int i = 0; i < addresses.length; i++) {
      addresses[i].isDefault = i == index;
    }

    // Perform Firestore update in the background
    final snapshot = await addressCollection.get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      final docId = snapshot.docs[i].id;
      await addressCollection.doc(docId).update({
        'isDefault': i == index,
      });
    }
  }
}