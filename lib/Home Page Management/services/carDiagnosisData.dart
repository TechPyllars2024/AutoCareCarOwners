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
      carDetailsMap[doc.id] = doc.data(); // Assuming no additional model mapping is needed
    }

    logger.i('Car details fetched successfully.');
    return carDetailsMap;
  } catch (error) {
    logger.e('Error fetching car details: $error');
    return {};
  }
}
}

