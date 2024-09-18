import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:autocare_carowners/ServiceDirectory/widgets//dropdown.dart';
import 'package:get/get.dart';

class Booking extends StatefulWidget {
  final String serviceName; // This will be used directly
  final String shopName;    // This will be used directly

  const Booking({super.key, required this.serviceName, required this.shopName});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final DropdownController dropdownController = Get.put(DropdownController());


  // Define constants used in buildTopSection
  final double coverHeight = 220;
  final double profileHeight = 130;
  final double top = 220 - 130 / 2; // Example calculation


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName), // Use the passed serviceName
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 8),
            children: [
              buildTopSection(), // Use the same top section
              buildShopName(),  // Use the same shop name
              ShopInformation(),



              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 15),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),

              ServiceSelection(),
              pickService()

              // Fetch the same shop information
              // Add other relevant content if needed
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopSection() {
    // Assuming buildTopSection uses serviceName and shopName
    double rating = 3;
    int numberOfRating = 33;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(),
        ),
        Positioned(
          left: 20,
          top: top,
          child: buildProfileImage(),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildShopName() => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.shopName, // Use shopName from Booking
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                'Location details', // You can also use the same location details if needed
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget ShopInformation() {
    const String openTime = '7:00';
    const String closeTime = '5:00';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.message, color: Colors.orange, size: 40,),
              const Padding(
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
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.call, color: Colors.orange, size: 40,),
              const Padding(
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
              const Icon(Icons.access_time, color: Colors.orange, size: 40,),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "$openTime - $closeTime",
                  style: const TextStyle(
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
              const Icon(Icons.location_on_outlined, color: Colors.orange, size: 40,),
              const Padding(
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

  // Example of methods you need to define
  Widget buildCoverImage() => Container(
    color: Colors.grey,
    child: Image.network(
      'https://www.erieinsurance.com/-/media/images/blog/articlephotos/2018/rentalcarlg.ashx?h=529&w=1100&la=en&hash=B6312A1CFBB03D75789956B399BF6B91E7980061',
      width: double.infinity,
      height: coverHeight,
      fit: BoxFit.cover,
    ),
  );

  Widget buildProfileImage() => CircleAvatar(
    radius: profileHeight / 2,
    backgroundColor: Colors.grey.shade800,
    backgroundImage: const NetworkImage(
      'https://cdn.vectorstock.com/i/500p/57/48/auto-repair-service-logo-badge-emblem-template-vector-49765748.jpg',
    ),
  );







  Widget ServiceSelection() => Column(
    children: [
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              'Other Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
          ],
        ),
      ),
      SizedBox(
        height: 220,
        child: CarouselView(
          itemExtent: 280,
          children: List.generate(10, (int index) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Create TextPainters for both texts to measure their widths
                final TextPainter firstTextPainter = TextPainter(
                  text: const TextSpan(
                    text: 'Car Wash', // This is the first text
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout();

                final TextPainter secondTextPainter = TextPainter(
                  text: const TextSpan(
                    text: 'Starts at XXXX', // This is the second text
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  maxLines: 1,
                  textDirection: TextDirection.ltr,
                )..layout();

                // Check if there's enough space for both texts
                final bool canFitBothTexts = constraints.maxWidth >
                    firstTextPainter.width + secondTextPainter.width + 20; // Adding some padding

                return Container(
                  child: Stack(
                    children: [
                      // ClipRRect to add curved corners and crop the bottom
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20), // Curve on the left
                            topRight: Radius.circular(20), // Curve on the right
                          ),
                          child: FractionallySizedBox(
                            heightFactor: 0.80,
                            alignment: Alignment.topCenter,
                            child: Image.network(
                              'https://soaphandcarwash.com/wp-content/uploads/2019/08/Soap-Hand-Car-Wash-13.jpg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      // Overlay Text in the bottom 25% space
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 50, // Allocating 25% space for text
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Text(
                                'Car Wash',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (canFitBothTexts) // Show second text only if both can fit
                                const Text(
                                  'Starts at XXXX',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,

                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  color: Colors.orangeAccent.shade100,
                );
              },
            );
          }),
        ),
      ),
    ],
  );




  Widget pickService() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service Specialization',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        CustomDropdown(
          options: const [
            'Electrical Works',
            'Mechanical Works',
            'Air-conditioning',
            'Paint and Body Works',
            'Car Wash and Auto-Detailing'
          ],
          hintText: 'Service Specialization',
          controller: dropdownController,
          onSelectionChanged: (selectedOptions) {
            print('Selected Options: $selectedOptions');
          },
        ),
      ],
    ),
  );


}

