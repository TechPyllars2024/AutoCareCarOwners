import 'package:flutter/material.dart';
import 'shop_profile.dart'; // Import ShopProfile page
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';

class Shop {
  final String name;
  final String imageUrl;

  Shop(this.name, this.imageUrl);
}

double rating = 4.0;

class ShopsDirectory extends StatefulWidget {
  final String serviceName; // Accept serviceName as a parameter
  final Widget? child;

  const ShopsDirectory({super.key, required this.serviceName, this.child});

  @override
  State<ShopsDirectory> createState() => _ShopsDirectoryState();
}

class _ShopsDirectoryState extends State<ShopsDirectory> {
  List<Shop> services = [
    Shop('Auto Garage', 'https://s3-media0.fl.yelpcdn.com/bphoto/FIOY7YvGejZ5ewzfGkaVvw/348s.jpg'),
    Shop('Car Care', 'https://static.vecteezy.com/system/resources/thumbnails/028/121/964/small_2x/car-logo-illustration-vector.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          widget.serviceName,
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 3,
                mainAxisSpacing: 8,
                childAspectRatio: 2 / .7, // 2:1 aspect ratio
              ),
              itemCount: services.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  // Navigate to ShopProfile and pass the serviceName and shopName
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShopProfile(
                        serviceName: widget.serviceName,
                        shopName: services[index].name,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 8,
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
                                services[index].imageUrl,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Shop name
                                  Text(
                                    services[index].name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),

                                  // Location row with icon and address
                                  Row(
                                    children: [
                                       Icon(
                                        Icons.location_on,
                                        color: Colors.orange.shade900,
                                         size: 15,
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        '123 Main St', // Example address
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
                        right: 8,
                        child: PannableRatingBar(
                          rate: rating,
                          items: List.generate(5, (index) =>
                           RatingWidget(
                            selectedColor: Colors.orange.shade900,
                            unSelectedColor: Colors.grey,
                            child: Icon(
                              Icons.star,
                              size: 12,
                            ),
                          )),
                          // Removed the onChanged callback to make it non-adjustable
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
