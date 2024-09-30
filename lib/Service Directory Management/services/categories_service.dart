import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../Ratings and Feedback Management/models/feedback_model.dart';
import '../models/services_model.dart';

class CategoriesService {
  late CollectionReference addressCollection;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final logger = Logger();

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

  // Caching and pagination variables
  Map<String, List<Map<String, dynamic>>> serviceCache = {};
  Map<String, DocumentSnapshot?> lastDocumentCache = {};

  // Fetch services under a specific category with pagination and caching
  Future<List<Map<String, dynamic>>> fetchServicesByCategory(String category,
      {bool refresh = false, int limit = 10}) async {
    // Check if we have cached data and if we don't want to refresh
    if (!refresh && serviceCache.containsKey(category)) {
      return serviceCache[category]!;
    }

    List<Map<String, dynamic>> services = [];

    try {
      Query query = firestore
          .collection('services')
          .where('category', arrayContains: category)
          .limit(limit);

      // Use lastDocumentCache for pagination
      if (lastDocumentCache.containsKey(category) &&
          lastDocumentCache[category] != null) {
        query = query.startAfterDocument(lastDocumentCache[category]!);
      }

      QuerySnapshot querySnapshot = await query.get();
      services = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Asynchronously check verification status for each service
      List<Map<String, dynamic>> verifiedServices = [];
      for (var service in services) {
        String uid = service['uid'];
        bool isVerified = await isProviderVerified(uid);
        if (isVerified) {
          verifiedServices.add(service);
        }
      }

      // Update the last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        lastDocumentCache[category] = querySnapshot.docs.last;
      }

      // Cache the fetched services
      if (verifiedServices.isNotEmpty) {
        serviceCache[category] = verifiedServices;
      }
      return verifiedServices;
    } catch (e) {
      logger.i('Error fetching services for category "$category": $e');
      return [];
    }
  }

  // Fetch service provider by uid
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

  // Fetch all services for a particular service provider
  Stream<List<ServiceModel>> fetchServices(String serviceProviderId) {
    return firestore
        .collection('services')
        .where('uid', isEqualTo: serviceProviderId)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
        .toList())
        .handleError((e) {
      logger.i('Error fetching services for provider ID $serviceProviderId: $e');
    });
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

  Stream<List<FeedbackModel>> fetchFeedbacks(String serviceProviderUid) {
    return firestore
        .collection('feedback')
        .where('serviceProviderUid', isEqualTo: serviceProviderUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
        .toList())
        .handleError((e) {
      logger.i('Error fetching feedbacks for provider ID $serviceProviderUid: $e');
    });
  }
}
