import 'package:autocare_carowners/ProfileManagement/models/car_owner_car_details_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarDetailsService {
  late CollectionReference carDetailsCollection;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CarDetailsService() {
    _initializeFirestore();
  }

  void _initializeFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      carDetailsCollection = FirebaseFirestore.instance
          .collection('car_owner_profile')
          .doc(user.uid)
          .collection('carDetails');
    }
  }

  Future<List<CarDetailsModel>> fetchCarDetails() async {
    final snapshot = await carDetailsCollection.get();
    return snapshot.docs
        .map((doc) =>
            CarDetailsModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCarDetails(CarDetailsModel carDetails) async {
    await carDetailsCollection.add(carDetails.toMap());
  }

  Future<void> editCarDetails(String docId, CarDetailsModel carDetails) async {
    await carDetailsCollection.doc(docId).update(carDetails.toMap());
  }

  Future<void> deleteCarDetails(String docId) async {
    await carDetailsCollection.doc(docId).delete();
  }
}
