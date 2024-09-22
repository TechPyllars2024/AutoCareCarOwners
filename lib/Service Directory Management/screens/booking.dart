import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:autocare_carowners/Service Directory Management//widgets//checklist.dart';
import 'package:autocare_carowners/Service Directory Management/widgets//timeSelection.dart';
import 'package:autocare_carowners/Service Directory Management/widgets//dropdown.dart';
import 'package:autocare_carowners/Service Directory Management/widgets//button.dart';
import 'package:autocare_carowners/Service Directory Management/widgets//dateSelection.dart';
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
  final brandController = DropdownController();


  // Define constants used in buildTopSection
  final double coverHeight = 220;
  final double profileHeight = 130;
  final double top = 220 - 130 / 2; // Example calculation


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),


              pickService(),

              timeSelection(),
              carDetails(),
              SubmitButton()

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











  Widget pickService() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Service',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Checklist(
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



  Widget timeSelection() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date and Time',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  

                  Expanded(
                    child: Container(
                      width: 200, // Set the same fixed width for this container
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey), // Border color
                      ),
                      child: DatePickerDisplay(
                        initialDate: DateTime.now(),
                        textStyle: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Add some space between the text and container
                  Expanded(
                    child: Container(
                      width: 200, // Set a fixed width for the container
                      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey), // Border color
                      ),
                      child: TimePickerDisplay(initialTime: TimeOfDay.now()),
                    ),
                  ),

                   // Add some space between the date picker and the time picker


                ],
              )


            ),
          ],
        ),
      ],
    ),
  );



  Widget carDetails() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Car Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0), // Optional spacing between the title and the row
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the row
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Brand', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  CustomDropdown<String>(
                    items: const [
                      'Toyota',
                      'Mitsubishi',
                      'Honda',
                      'Ford',
                      'Nissan',
                      'Kia',
                      'Suzuki',
                      'Isuzu',
                    ],
                    initialValue: 'Toyota',
                    onChanged: (selectedOption) {
                      print('Selected Option: $selectedOption');
                    },
                    dropdownColor: Colors.grey.shade500, // Optional customization
                    underlineColor: Colors.grey.shade800, // Optional customization
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.0), // Space between columns
            Expanded(
              child: Column(
                children: [
                  Text('Model', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  CustomDropdown<String>(
                    items: const [
                      'aaa',
                      'bbb',
                      'ccc',
                      'ddd',
                      'eee',
                      'Kia',
                    ],
                    initialValue: 'aaa',
                    onChanged: (selectedOption) {
                      print('Selected Option: $selectedOption');
                    },
                    dropdownColor: Colors.grey.shade500, // Optional customization
                    underlineColor: Colors.grey.shade800, // Optional customization
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.0), // Space between columns
            Expanded(
              child: Column(
                children: [
                  Text('Year', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  CustomDropdown<String>(
                    items: const [
                      '1111',
                      '2222',
                      '3333',
                      '4444',
                      '5555',
                      '6666',
                    ],
                    initialValue: '1111',
                    onChanged: (selectedOption) {
                      print('Selected Option: $selectedOption');
                    },
                    dropdownColor: Colors.grey.shade500, // Optional customization
                    underlineColor: Colors.grey.shade800, // Optional customization
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );


  Widget SubmitButton() => Center(
    child: WideButtons(onTap: () {
      // Define what happens when the button is tapped
    },
      text: 'Submit',
      color: Colors.orange,),
  );







}

