import 'package:autocare_carowners/Booking%20Management/screens/booking.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';

import '../../Ratings and Feedback Management/models/feedback_model.dart';
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
  final double coverHeight = 160;
  final double profileHeight = 100;

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

  bool isExpanded = false;

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
                      EdgeInsets.only(right: 16.0,left: 16, top: 20,),
                      child: Divider(thickness: 1, color: Colors.grey),
                    ),
                    servicesCarousel(),
                    feedbackSection(widget.serviceProviderUid),
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
        data['totalRatings'] ?? 0;
    int numberOfRating =
        data['numberOfRatings'] ?? 0;

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
                      (index) =>  RatingWidget(
                    selectedColor: Colors.orange.shade900,
                    unSelectedColor: Colors.grey,
                    child: const Icon(
                      Icons.star,
                      size: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$numberOfRating ratings',
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange.shade900, size: 15,),
              const SizedBox(width: 4),
              Text(
                data['location'] ?? 'Location details',
                //  style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.orange.shade900, size: 15,),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      data['daysOfTheWeek'].join(', ') ?? 'Operating Days',
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check, color: Colors.orange.shade900, size: 15,),
                  const SizedBox(width: 4),
                  Expanded(

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['serviceSpecialization'].join(', ') ??
                              'Specialization',
                          style: const TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget shopInformation(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, color: Colors.orange.shade900, size: 25),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call, color: Colors.orange.shade900, size: 25),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Call',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_filled, color: Colors.orange.shade900, size: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data['operationTime'] ?? 'Operation Time',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.orange.shade900, size: 25),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Direction",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
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
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        color: Colors.grey.shade200,
                      ),
                      margin: const EdgeInsets.all(5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 8,

                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                  ),
                                  color: Colors.white,
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: service.servicePicture.isNotEmpty
                                    ? Image.network(
                                  service.servicePicture,
                                  height: 100,
                                  width: double.infinity,  // Ensure the image fills the container's width
                                  fit: BoxFit.cover,
                                )
                                    : const Placeholder(),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold),),

                                    Text('Starts at Php ${service.price}', style: const TextStyle(fontSize: 13),),
                                  ],
                                ),
                              ),
                            ),

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

  Widget feedbackSection(String serviceProviderUid) {
    return StreamBuilder<List<FeedbackModel>>(
      stream: CategoriesService().fetchFeedbacks(serviceProviderUid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No feedbacks available.'));
        } else {
          final feedbacks = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(
                height: 150,

                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.85),
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PhysicalModel(
                        color: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.grey,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.blueGrey[50],
                                      child: Text(
                                        feedback.feedbackerName[0], // First letter of the feedbacker's name
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        feedback.feedbackerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isExpanded = !isExpanded;
                                        });
                                      },
                                      child: Text(
                                        feedback.comment,
                                        style: TextStyle(
                                          fontSize: isExpanded ? 12 : 13, // Decrease font size if expanded
                                          color: Colors.black54,
                                        ),
                                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                        maxLines: isExpanded ? null : 2, // Show all lines if expanded
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),


                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                         Icon(Icons.star, color: Colors.orange.shade900, size: 16),
                                        const SizedBox(width: 5),
                                        Text(
                                          feedback.rating.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatTimestamp(feedback.timestamp), // Function to format timestamp
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }

// Helper function to format the timestamp
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}