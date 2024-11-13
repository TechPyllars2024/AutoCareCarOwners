import 'package:autocare_carowners/ProfileManagement/models/car_owner_car_details_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class CarDetailsService {
  late CollectionReference carDetailsCollection;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final logger = Logger();

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
    try {
      final snapshot = await carDetailsCollection.get();
      return snapshot.docs
          .map((doc) =>
              CarDetailsModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.i('Error fetching car details: $e');
      throw Exception('Unable to fetch car details. Please try again later.');
    }
  }

  Future<void> addCarDetails(CarDetailsModel carDetails) async {
    try {
      await carDetailsCollection.add(carDetails.toMap());
    } catch (e) {
      logger.i('Error adding car details: $e');
      throw Exception('Failed to add car details. Please try again.');
    }
  }

  Future<void> editCarDetails(String docId, CarDetailsModel carDetails) async {
    try {
      await carDetailsCollection.doc(docId).update(carDetails.toMap());
    } catch (e) {
      logger.i('Error updating car details: $e');
      throw Exception('Failed to update car details. Please try again.');
    }
  }

  Future<void> deleteCarDetails(String docId) async {
    try {
      await carDetailsCollection.doc(docId).delete();
    } catch (e) {
      logger.i('Error deleting car details: $e');
      throw Exception('Failed to delete car details. Please try again.');
    }
  }

  // Set a default car (updating the Firestore and the local list)
  Future<void> setDefaultCar(int index, List<CarDetailsModel> carDetails) async {
    try {
      // Update the local state immediately
      for (int i = 0; i < carDetails.length; i++) {
        carDetails[i].isDefault = i == index;  // Set the default car
      }

      // Perform Firestore update in the background
      final snapshot = await carDetailsCollection.get();
      for (int i = 0; i < snapshot.docs.length; i++) {
        final docId = snapshot.docs[i].id;
        await carDetailsCollection.doc(docId).update({
          'isDefault': i == index,
        });
      }
    } catch (e) {
      logger.e('Error setting default car: $e');
      throw Exception('Unable to set default car. Please try again.');
    }
  }
}

class CapitalizeEachWordFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Capitalize the first letter of each word
    String text = newValue.text
        .split(' ') // Split the input text by spaces to get individual words
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' '); // Rejoin the words with spaces

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
