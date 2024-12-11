import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class CarDiagnosis {
// Instantiate Firestore and Logger
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  Future<Map<String, dynamic>> fetchCarDetails(String carOwnerUid) async {
    try {
      if (carOwnerUid.isEmpty) {
        logger.e('Invalid carOwnerUid');
        return {};
      }

      final carDetailsCollection = firestore
          .collection('car_owner_profile')
          .doc(carOwnerUid)
          .collection('carDetails');

      final snapshot = await carDetailsCollection.get();
      logger.i('Car details snapshot for user: $carOwnerUid');

      if (snapshot.docs.isEmpty) {
        logger.i('No car details found for this user.');
        return {};
      }

      Map<String, dynamic> carDetailsMap = {};

      for (var doc in snapshot.docs) {
        carDetailsMap[doc.id] =
            doc.data(); // Assuming no additional model mapping is needed
      }

      logger.i('Car details fetched successfully.');
      return carDetailsMap;
    } catch (error) {
      logger.e('Error fetching car details: $error');
      return {};
    }
  }

  // Fetch all unique categories from the services collection
  Future<List<String>> fetchServiceCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('services').get();

      // Extract categories from each document and flatten the list
      List<String> categories = querySnapshot.docs
          .map((doc) => List<String>.from(doc['category']))
          .expand((categoryList) => categoryList)
          .toList();

      // Remove duplicates
      categories = categories.toSet().toList();

      return categories;
    } catch (e) {
      logger.i('Error fetching service categories: $e');
      return [];
    }
  }

  // Fetch all unique categories from the services collection
  Future<List<String>> fetchServiceNames() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('services').get();

      // Extract categories from each document and flatten the list
      List<String> serviceNames = querySnapshot.docs
          .map((doc) => List<String>.from(doc['name']))
          .expand((categoryList) => categoryList)
          .toList();

      // Remove duplicates
      serviceNames = serviceNames.toSet().toList();

      return serviceNames;
    } catch (e) {
      logger.i('Error fetching service categories: $e');
      return [];
    }
  }
}
