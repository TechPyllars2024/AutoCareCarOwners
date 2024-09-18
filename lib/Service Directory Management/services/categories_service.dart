import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesService {
  late CollectionReference addressCollection;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch all unique categories from the services collection
  Future<List<String>> fetchServiceCategories() async {
    try {
      QuerySnapshot querySnapshot = await firestore.collection('services').get();

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

}