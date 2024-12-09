import 'package:autocare_carowners/Service%20Directory%20Management/screens/shops_directory.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autocare_carowners/Service%20Directory%20Management/services/categories_service.dart';
import 'package:logger/logger.dart';

class Service {
  final String name;
  final String imageUrl;
  bool isAvailable;

  Service(this.name, this.imageUrl, this.isAvailable);
}

class ServiceDirectoryScreen extends StatefulWidget {
  const ServiceDirectoryScreen({super.key, this.child});

  final Widget? child;

  @override
  State<ServiceDirectoryScreen> createState() => _AutomotiveServicesState();
}

class _AutomotiveServicesState extends State<ServiceDirectoryScreen> {
  List<Service> services = [
    Service(
        'Electrical Works',
        'https://i0.wp.com/www.profixautocare.com/wp-content/uploads/2020/05/image-27.png',
        false),
    Service(
        'Mechanical Works',
        'https://static.wixstatic.com/media/24457cc02d954991b6aafb169233cc46.jpg/v1/fill/w_1480,h_986,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/24457cc02d954991b6aafb169233cc46.jpg',
        false),
    Service(
        'Air-conditioning Services',
        'https://reddevilradiators.com.au/wp-content/uploads/2019/12/Screen-Shot-2019-12-14-at-1.28.18-pm.png',
        false),
    Service(
        'Paint and Body Works',
        'https://www.supersybon.com/wp-content/uploads/2023/04/1681353422-Metallic-Black-Car-Paint-The-Ultimate-Guide-for-Car-Enthusiasts.jpg',
        false),
    Service(
        'Car Wash',
        'https://koronapos.com/wp-content/uploads/2022/01/car-wash-1200x675.png',
        false),
    Service(
        'Auto Detailing Services',
        'https://the-car-wash.com/wp-content/uploads/2017/09/intext-cleaning.jpg',
        false),
    Service(
        'Roadside Assistance Services',
        'https://imgcdnblog.carmudi.com.ph/wp-content/uploads/2024/09/12194250/image-1058.jpg?resize=500x333',
        false),
    Service(
        'Installation of Accessories Services',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRwwc4VlJ71PGy6Fjn9EadMvMN30F4f5OuL3R_QWXdnQ-Va0yDHBOzGQDVEYu106ZTimg&usqp=CAU',
        false)
  ];
  final logger = Logger();

  final CategoriesService categoriesService = CategoriesService();
  List<String> availableCategories = [];
  bool isLoading = true;

  // Update availability based on category match
  void updateServiceAvailability(List<String> availableServices) {
    setState(() {
      for (var service in services) {
        // Check if service.name exists in availableServices
        bool isAvailable = availableServices.contains(service.name);
        service.isAvailable = isAvailable;
        logger.i('Service ${service.name} is available: $isAvailable');
      }
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch verified services and update availability
    fetchVerifiedServicesForCategories().then((verifiedServices) {
      updateServiceAvailability(verifiedServices);
    });
  }

  // Fetch categories dynamically from Firebase and update the availability
  Future<List<String>> fetchServiceCategories() async {
    try {
      // Fetch all service documents from Firebase Firestore
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('services').get();

      // Extract categories from each document and flatten the list
      List<String> categories = querySnapshot.docs
          .map((doc) => List<String>.from(
              doc['category'])) // Extract category list from each document
          .expand(
              (categoryList) => categoryList) // Flatten the list of categories
          .toList();

      // Remove duplicates to get unique categories
      categories = categories.toSet().toList();

      // Return the list of categories
      return categories;
    } catch (e) {
      // Handle errors
      logger.i('Error fetching service categories: $e');
      return [];
    }
  }

  Future<List<String>> fetchVerifiedServicesForCategories() async {
    try {
      // Fetch categories
      List<String> categories = await fetchServiceCategories();

      List<String> categoriesWithVerifiedServices = [];

      for (String category in categories) {
        // Fetch verified services for each category
        List<Map<String, dynamic>> servicesData =
            await categoriesService.fetchServicesByCategory(category);

        // Check if there are any verified services for this category
        if (servicesData.isNotEmpty) {
          categoriesWithVerifiedServices.add(category);
          logger.i('Category $category has verified services');
        }
      }
      // Return the list of categories with verified services
      logger.i(
          'Categories with verified services: $categoriesWithVerifiedServices');
      return categoriesWithVerifiedServices;
    } catch (e) {
      // Handle error and log
      logger.i('Error fetching categories with verified services: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter services to only include those that are available
    List<Service> availableServices =
        services.where((service) => service.isAvailable).toList();
    logger.i('Available services: $availableServices');

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Services',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        elevation: 0,
        actions: const [],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(bottom: 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 2,
                      childAspectRatio: 2 / .8,
                    ),
                    itemCount: availableServices.length,
                    itemBuilder: (context, index) => GestureDetector(
                      onTap: () {
                        // Navigate to ShopsDirectory with service name as argument
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopsDirectory(
                                serviceName: availableServices[index].name),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  bottomLeft: Radius.circular(15.0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: availableServices[index].imageUrl,
                                  placeholder: (context, url) => Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(50.0),
                                      child: SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.orange.shade900),
                                          strokeWidth: 3.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  availableServices[index].name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
