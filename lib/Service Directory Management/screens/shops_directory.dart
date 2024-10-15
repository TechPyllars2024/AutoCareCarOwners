import 'package:flutter/material.dart';
import '../services/categories_service.dart';
import 'shop_profile.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';

class ShopsDirectory extends StatefulWidget {
  final String serviceName;
  final Widget? child;

  const ShopsDirectory({super.key, required this.serviceName, this.child});

  @override
  State<ShopsDirectory> createState() => _ShopsDirectoryState();
}

class _ShopsDirectoryState extends State<ShopsDirectory> {
  List<Map<String, dynamic>> services = [];
  bool isLoading = false;
  CategoriesService service = CategoriesService();
  int limit = 10;
  bool hasMoreServices = true;

  // Cache for fetched services by category
  Map<String, List<Map<String, dynamic>>> serviceCache = {};

  Map<int, bool> isTextExpanded = {};

  @override
  void initState() {
    super.initState();
    getServicesForCategory(widget.serviceName);
  }

  void getServicesForCategory(String category, {bool refresh = false}) async {
    if (isLoading || !hasMoreServices) return;
    setState(() {
      isLoading = true;
    });

    // Check if services are already cached
    if (!refresh && serviceCache.containsKey(category)) {
      services = serviceCache[category]!;
      setState(() {
        isLoading = false;
      });
      return; // Return early if services are found in the cache
    }

    List<Map<String, dynamic>> fetchedServices = await service
        .fetchServicesByCategory(category, refresh: refresh, limit: limit);

    // If no more services are fetched, set hasMoreServices to false
    if (fetchedServices.isEmpty) {
      hasMoreServices = false;
    } else {
      // Fetch service providers that match the service uid
      for (var serviceData in fetchedServices) {
        var providerDetails =
        await service.fetchProviderByUid(serviceData['uid']);

        // Combine the service data with the provider data
        services.add({
          ...serviceData,
          'shopName': providerDetails['shopName'],
          'location': providerDetails['location'],
          'operationTime': providerDetails['operationTime'],
          'profileImage': providerDetails['profileImage'],
          'coverImage': providerDetails['coverImage'],
          'serviceSpecialization': providerDetails['serviceSpecialization'],
          'daysOfTheWeek': providerDetails['daysOfTheWeek'],
          'verificationStatus': providerDetails['verificationStatus'],
          'totalRatings': providerDetails['totalRatings'],
          'numberOfRatings': providerDetails['numberOfRatings'],
        });
      }

      // Cache the fetched services
      serviceCache[category] = List.from(services); // Store a copy of the services list
    }

    setState(() {
      isLoading = false; // Reset loading state
    });
  }

  // Call this method to load more services when needed (e.g., on scroll)
  void loadMoreServices() {
    if (!isLoading && hasMoreServices) {
      getServicesForCategory(widget.serviceName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          widget.serviceName,
          style: TextStyle(
              fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: services.isNotEmpty
              ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 5,
              mainAxisSpacing: 8,
              childAspectRatio: 2 / .8, // 2:1 aspect ratio
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index]; // Get the service details

              bool isExpanded = isTextExpanded[index] ?? false;

              return GestureDetector(
                onTap: () {
                  // Navigate to ShopProfile and pass service details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopProfile(
                        serviceProviderUid: service['uid'],
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                bottomLeft: Radius.circular(16.0),
                              ),
                              child: Image.network(
                                service['servicePicture'],
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  // Service name with icon
                                  Row(
                                    children: [
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              // Toggle expand/collapse state
                                              isTextExpanded[index] =
                                              !(isTextExpanded[index] ??
                                                  false);
                                            });
                                          },
                                          child: Text(
                                            service['name'] ?? '',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: isExpanded ? null : 1, // If expanded, show full text
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis, // If collapsed, show ellipsis
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3.0),
                                  // Service location with icon
                                  Row(
                                    children: [
                                      Icon(Icons.store,
                                          size: 15,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              // Toggle expand/collapse state
                                              isTextExpanded[index] =
                                              !(isTextExpanded[index] ??
                                                  false);
                                            });
                                          },
                                          child: Text(
                                            service['shopName'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: isExpanded ? null : 1, // If expanded, show full text
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis, // If collapsed, show ellipsis
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3.0),
                                  // Service name with icon
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 15,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              // Toggle expand/collapse state
                                              isTextExpanded[index] =
                                              !(isTextExpanded[index] ??
                                                  false);
                                            });
                                          },
                                          child: Text(
                                            service['location'] ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: isExpanded ? null : 1, // If expanded, show full text
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis, // If collapsed, show ellipsis
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3.0),
                                  // Price with icon
                                  Row(
                                    children: [
                                      const SizedBox(width: 4),
                                      Text(
                                        'Starts at: Php ${service['price']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Align the rating at the bottom right
                      Positioned(
                        bottom: 8,
                        right: 12,
                        child: PannableRatingBar(
                          rate: (service['totalRatings'] != null && service['numberOfRatings'] != null && service['numberOfRatings'] > 0)
                              ? (service['totalRatings'] as double) / (service['numberOfRatings'] as int) // Calculate the average rating
                              : 0.0,
                          direction: Axis.horizontal,
                          items: List.generate(
                              5,
                                  (index) => RatingWidget(
                                selectedColor: Colors.orange.shade900,
                                unSelectedColor: Colors.grey,
                                child: const Icon(
                                  Icons.star,
                                  size: 14,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
              : const Center(
            child: Text('No Shops Available'),
          ),
        ),
      ),
    );
  }
}
