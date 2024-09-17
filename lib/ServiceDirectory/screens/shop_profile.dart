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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Keep the AppBar title as the serviceName
          title: Text(widget.serviceName),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView(
                padding: EdgeInsets.only(bottom: 8),
                children: [

                  buildCoverImage(),
               //   buildProfileImage(),
                ],
              ),
        )));
  }




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
        // Positioned(
        //   left: 20,
        //   top: top,
        //   child: buildProfileImage(),
        // ),
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
                onChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
              SizedBox(width: 5),
              Text(
                '$numberOfRating ratings',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

  //
  // Widget buildProfileImage() => CircleAvatar(
  //   radius: profileHeight / 2,
  //   backgroundColor: Colors.grey.shade800,
  //   backgroundImage: NetworkImage(
  //     'https://cdn.vectorstock.com/i/500p/57/48/auto-repair-service-logo-badge-emblem-template-vector-49765748.jpg',
  //   ),
  // );


}






