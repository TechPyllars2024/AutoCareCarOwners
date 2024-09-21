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

  get rating => 5.0;

  @override
  void initState() {
    super.initState();
    getServicesForCategory(widget.serviceName);
  }

  void getServicesForCategory(String category, {bool refresh = false}) async {
    if (isLoading || !hasMoreServices) return; // Prevent multiple calls
    setState(() {
      isLoading = true;
    });

    List<Map<String, dynamic>> fetchedServices = await service
        .fetchServicesByCategory(category, refresh: refresh, limit: limit);

    // If no more services are fetched, set hasMoreServices to false
    if (fetchedServices.isEmpty) {
      hasMoreServices = false;
    } else {
      // Fetch service providers that match the service `uid`
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
        });
      }
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
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Text(
          widget.serviceName,
          style:
              TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
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
                                            Icon(Icons.build_circle,
                                                size: 20,
                                                color: Colors.grey[800]),
                                            const SizedBox(width: 4),
                                            Text(
                                              service['name'],
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 1.0),
                                        // Service location with icon
                                        Row(
                                          children: [
                                            Icon(Icons.store,
                                                size: 20,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              service['shopName'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Service name with icon
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 20,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              service['location'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 1.0),
                                        // Price with icon
                                        Row(
                                          children: [
                                            Icon(Icons.attach_money,
                                                size: 20,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Price: ${service['price']}',
                                              style: TextStyle(
                                                fontSize: 14,
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
                              bottom: 2,
                              right: 8,
                              child: PannableRatingBar(
                                rate: rating,
                                items: List.generate(
                                    5,
                                    (index) => const RatingWidget(
                                          selectedColor: Colors.orange,
                                          unSelectedColor: Colors.grey,
                                          child: Icon(
                                            Icons.star,
                                            size: 20,
                                          ),
                                        )),
                                // Removed the onChanged callback to make it non-adjustable
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child:
                      CircularProgressIndicator(), // Show a loading indicator while fetching data
                ),
        ),
      ),
    );
  }
}
