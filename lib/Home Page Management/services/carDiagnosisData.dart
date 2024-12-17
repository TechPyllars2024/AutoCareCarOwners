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

  // Fetch all service names, descriptions, and service IDs from the services collection that have verified providers
  Future<List<Map<String, dynamic>>> fetchVerifiedServiceDetails() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('services').get();

      // Extract and filter the list of service details
      List<Map<String, dynamic>> verifiedServiceDetails = [];

      for (var doc in querySnapshot.docs) {
        var serviceData = doc.data() as Map<String, dynamic>;

        // Check if the provider for this service is verified
        bool isVerified = await isProviderVerified(doc['uid']);

        if (isVerified) {
          verifiedServiceDetails.add({
            'name': serviceData['name'].toString(),
            'description': serviceData['description'].toString(),
            'serviceID': doc.id,
            'uid' : serviceData['uid'].toString(),
          });
        }
      }

      return verifiedServiceDetails;
    } catch (e) {
      logger.i('Error fetching verified service details: $e');
      return [];
    }
  }

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

  Future<Map<String, dynamic>> fetchProviderByUid(String uid) async {
    try {
      DocumentSnapshot providerSnapshot = await FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(uid)
          .get();

      return providerSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      logger.i('Error fetching provider by UID $uid: $e');
      return {};
    }
  }


  // Helper function to check if a provider is verified
  Future<bool> isProviderVerified(String uid) async {
    try {
      DocumentSnapshot providerSnapshot = await firestore
          .collection('automotiveShops_profile')
          .doc(uid)
          .get();

      if (providerSnapshot.exists) {
        var providerData = providerSnapshot.data() as Map<String, dynamic>;
        return providerData['verificationStatus'] == 'Verified';
      }
    } catch (e) {
      logger.i('Error checking provider verification status for UID $uid: $e');
    }
    return false; // Return false if the provider does not exist or an error occurs
  }
}
