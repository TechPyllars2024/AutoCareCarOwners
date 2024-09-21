import 'package:autocare_carowners/Booking%20Management/screens/booking.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';

import '../models/services_model.dart';
import '../services/categories_service.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ShopProfile extends StatefulWidget {
  final String serviceProviderUid;
  final Widget? child;

  const ShopProfile({super.key, required this.serviceProviderUid, this.child});

  @override
  State<ShopProfile> createState() => _ShopProfileState();
}

class _ShopProfileState extends State<ShopProfile> {
  final double coverHeight = 220;
  final double profileHeight = 130;

  late Future<Map<String, dynamic>> _providerData;

  @override
  void initState() {
    super.initState();
    _providerData =
        CategoriesService().fetchProviderByUid(widget.serviceProviderUid);
  }

  void bookingRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Booking(
          serviceProviderUid: widget.serviceProviderUid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile'),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _providerData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data available.'));
            } else {
              final data = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    buildTopSection(data, top),
                    buildShopName(data),
                    shopInformation(data),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                      child: Divider(thickness: 1, color: Colors.grey),
                    ),
                    servicesCarousel(),
                    feedbackSection(),
                    bookingButton(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget bookingButton() => WideButtons(
        onTap: bookingRoute,
        text: 'Book Now!',
      );

  Widget buildTopSection(Map<String, dynamic> data, double top) {
    double rating =
        data['rating'] ?? 3.0;
    int numberOfRating =
        data['numberOfRating'] ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(data),
        ),
        Positioned(
          left: 20,
          top: top,
          child: buildProfileImage(data),
        ),
        Positioned(
          right: 20,
          top: coverHeight + 10,
          child: Row(
            children: [
              PannableRatingBar(
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
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$numberOfRating ratings',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildCoverImage(Map<String, dynamic> data) => Container(
        color: Colors.grey,
        child: Image.network(
          data['coverImage'] ?? 'default_cover_image_url',
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
        ),
      );

  Widget buildProfileImage(Map<String, dynamic> data) => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage:
            NetworkImage(data['profileImage'] ?? 'default_profile_image_url'),
      );

  Widget buildShopName(Map<String, dynamic> data) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['shopName'] ?? 'Unknown Shop',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    data['location'] ?? 'Location details',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    data['daysOfTheWeek'].join(', ') ?? 'Operating Days',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.check, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    data['serviceSpecialization'].join(', ') ??
                        'Specialization',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget shopInformation(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message, color: Colors.orange, size: 40),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Message',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.call, color: Colors.orange, size: 40),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Call',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, color: Colors.orange, size: 40),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  data['operationTime'] ?? 'Operation Time',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, color: Colors.orange, size: 40),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Direction",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget servicesCarousel() {
    final serviceProviderId = widget.serviceProviderUid;
    Future<List<ServiceModel>> fetchServices() async {
      final servicesStream =
          CategoriesService().fetchServices(serviceProviderId);
      final snapshot = await servicesStream.first;
      return snapshot;
    }

    return FutureBuilder<List<ServiceModel>>(
      future: fetchServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No services available.'));
        } else {
          final services = snapshot.data!;

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      'Other Services',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: CarouselSlider.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index, realIndex) {
                    final service = services[index];
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.shade300,
                      ),
                      margin: const EdgeInsets.all(5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            service.servicePicture.isNotEmpty
                                ? Image.network(
                                    service.servicePicture,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : const Placeholder(),
                            Text(service.name),
                            Text('${service.price} PHP'),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: 220,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget feedbackSection() => Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Feedbacks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paul Vincent Lerado',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                    child: Text(
                        'I was impressed with the professionalism and efficiency of your team during my recent oil change and brake inspection. '
                        'However, the service took longer than expected, so providing more accurate time estimates would be helpful.'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
