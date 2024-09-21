import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/services_model.dart';

class CategoriesService {
  late CollectionReference addressCollection;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

      // Update the last document for pagination
      if (querySnapshot.docs.isNotEmpty) {
        lastDocumentCache[category] = querySnapshot.docs.last;
      }

      // Cache the fetched services
      if (services.isNotEmpty) {
        serviceCache[category] = services;
      }

      return services;
    } catch (e) {
      return [];
    }
  }

  // Fetch service provider by uid
  Future<Map<String, dynamic>> fetchProviderByUid(String uid) async {
    DocumentSnapshot providerSnapshot = await FirebaseFirestore.instance
        .collection('automotiveShops_profile')
        .doc(uid)
        .get();

    return providerSnapshot.data() as Map<String, dynamic>;
  }

  // Fetch all services for a particular service provider
  Stream<List<ServiceModel>> fetchServices(String serviceProviderId) {
    return firestore
        .collection('services')
        .where('uid', isEqualTo: serviceProviderId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ServiceModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
