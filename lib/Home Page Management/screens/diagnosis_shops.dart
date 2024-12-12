import 'package:autocare_carowners/Home%20Page%20Management/services/carDiagnosisData.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../Service Directory Management/screens/shop_profile.dart';
import '../../Service Directory Management/services/categories_service.dart';
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
  Map<int, bool> isTextExpanded = {};
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    getServicesForCategory(widget.serviceName);
  }

  List<String> normalizeServiceNames(String serviceNames) {
    if (serviceNames.isEmpty) return [];

    List<String> splitNames = serviceNames.split(RegExp(r'\d+\.\s+|\n+'));

    // Normalize each service name and filter out empty entries
    return splitNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  void getServicesForCategory(String serviceName,
      {bool refresh = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      // Split and normalize service names
      List<String> serviceNames = normalizeServiceNames(serviceName);

      List<Map<String, dynamic>> allFetchedServices =
          (await CarDiagnosis().fetchVerifiedServiceDetails());

      for (var name in serviceNames) {
        List<Map<String, dynamic>> filteredServices =
            allFetchedServices.where((service) {
          return service['name'] != null && service['name'] == name;
        }).toList();

        if (filteredServices.isEmpty) {
          logger.i('No services found for the service name: $name');
        } else {
          for (var serviceData in filteredServices) {
            var providerDetails =
                await CarDiagnosis().fetchProviderByUid(serviceData['uid']);
            services.add({
              ...serviceData,
              'shopName': providerDetails['shopName'] ?? 'Unknown',
              'location': providerDetails['location'] ?? 'Unknown location',
              'operationTime': providerDetails['operationTime'] ?? 'Unknown',
              'profileImage': providerDetails['profileImage'] ?? '',
              'coverImage': providerDetails['coverImage'] ?? '',
              'serviceSpecialization':
                  providerDetails['serviceSpecialization'] ?? 'Not specified',
              'daysOfTheWeek':
                  providerDetails['daysOfTheWeek'] ?? 'Not specified',
              'verificationStatus':
                  providerDetails['verificationStatus'] ?? 'Not verified',
              'totalRatings': providerDetails['totalRatings'] ?? 0,
              'numberOfRatings': providerDetails['numberOfRatings'] ?? 0,
            });
          }
        }
      }
    } catch (e) {
      logger.e('An error occurred while fetching services: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          "Suggested Available Shops",
          style:
              TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: services.isNotEmpty
                  ? GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2 / .8,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        bool isExpanded = isTextExpanded[index] ?? false;

                        return GestureDetector(
                          onTap: () {
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
                                          service['profileImage'] ?? '',
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
                                            Row(
                                              children: [
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        isTextExpanded[index] =
                                                            !(isTextExpanded[
                                                                    index] ??
                                                                false);
                                                      });
                                                    },
                                                    child: Text(
                                                      service['name'] ??
                                                          'No name',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[800],
                                                      ),
                                                      maxLines:
                                                          isExpanded ? null : 1,
                                                      overflow: isExpanded
                                                          ? TextOverflow.visible
                                                          : TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3.0),
                                            Row(
                                              children: [
                                                Icon(Icons.store,
                                                    size: 15,
                                                    color:
                                                        Colors.orange.shade900),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        isTextExpanded[index] =
                                                            !(isTextExpanded[
                                                                    index] ??
                                                                false);
                                                      });
                                                    },
                                                    child: Text(
                                                      service['shopName'] ??
                                                          'No shop name',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                      maxLines:
                                                          isExpanded ? null : 1,
                                                      overflow: isExpanded
                                                          ? TextOverflow.visible
                                                          : TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3.0),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on,
                                                    size: 15,
                                                    color:
                                                        Colors.orange.shade900),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        isTextExpanded[index] =
                                                            !(isTextExpanded[
                                                                    index] ??
                                                                false);
                                                      });
                                                    },
                                                    child: Text(
                                                      service['location'] ??
                                                          'No location',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                      maxLines:
                                                          isExpanded ? null : 1,
                                                      overflow: isExpanded
                                                          ? TextOverflow.visible
                                                          : TextOverflow
                                                              .ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3.0),
                                            Row(
                                              children: [
                                                Icon(Icons.people,
                                                    size: 15,
                                                    color:
                                                        Colors.orange.shade900),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Number of Ratings: ${service['numberOfRatings']}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 12,
                                  child: PannableRatingBar(
                                    rate: (service['totalRatings'] != null &&
                                            service['numberOfRatings'] !=
                                                null &&
                                            service['numberOfRatings'] > 0)
                                        ? (service['totalRatings'] as double) /
                                            (service['numberOfRatings'] as int)
                                        : 0.0,
                                    direction: Axis.horizontal,
                                    items: List.generate(
                                      5,
                                      (index) => RatingWidget(
                                        selectedColor: Colors.orange.shade900,
                                        unSelectedColor: Colors.grey,
                                        child: const Icon(Icons.star, size: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('')),
            ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
              ),
          ],
        ),
      ),
    );
  }
}
