import 'package:autocare_carowners/ServiceDirectory/screens/booking.dart';
import 'package:autocare_carowners/ServiceDirectory/widgets//button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';


class ShopProfile extends StatefulWidget {
  final String serviceName; // Accept the serviceName
  final String shopName; // Accept the shopName

  //child: Text('Welcome to ${widget.shopName}'),

  const ShopProfile(
      {super.key, required this.serviceName, required this.shopName});

  @override
  State<ShopProfile> createState() => _ShopProfileState();
}

class _ShopProfileState extends State<ShopProfile> {
  final double coverHeight = 220;
  final double profileHeight = 130;

  bool isExpanded = false;


  void bookingRoute() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Booking(
          serviceName: widget.serviceName, // Pass serviceName to Booking
          shopName: widget.shopName,       // Pass shopName to Booking
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;




    return Scaffold(
        appBar: AppBar(
          // Keep the AppBar title as the serviceName
          title: Text(widget.serviceName),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  buildTopSection(top),
                  buildShopName(),
                  ShopInformation(),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),

                  ServicesCarousel(),
                  FeedbackSection(),
                  bookingButton()


                ],
              ),
        )));
  }

  Widget bookingButton() => WideButtons(
    onTap: bookingRoute,
    text: 'Book Now!',
  );


  Widget buildTopSection(double top) {
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


  Widget buildShopName() => const Padding(
    padding: EdgeInsets.all(16.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto Repair',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.orange),
              SizedBox(width: 4),
              Text(
                'Location details',
                style: TextStyle(fontSize: 15),
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

    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.message, color: Colors.orange, size: 40,),
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

          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.call, color: Colors.orange, size: 40,),
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
              Icon(Icons.access_time, color: Colors.orange, size: 40,),
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "${openTime} - ${closeTime}",
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
              Icon(Icons.location_on_outlined, color: Colors.orange, size: 40,),
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


  Widget ServicesCarousel() => Column(
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


  Widget FeedbackSection() => Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Feedbacks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // Curved edges
          ),
          child: const Padding(
            padding: EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Aligns the text to the left
              children: [
                Text('Paul Vincent Lerado', style: TextStyle(fontWeight: FontWeight.bold),),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                  child: Text('I was impressed with the professionalism and efficiency of your team during my recent oil change and brake inspection. '
                      'However, the service took longer than expected, so providing more accurate time estimates would be helpful.'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );





}





