import 'dart:async';
import 'package:autocare_carowners/Booking%20Management/services/booking_service.dart';
import 'package:autocare_carowners/Navigation%20Bar/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/checklist.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/time_selection.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/date_selection.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../Authentication/Widgets/snackBar.dart';
import '../../ProfileManagement/screens/car_owner_car_details.dart';
import '../../Service Directory Management/services/categories_service.dart';

class Booking extends StatefulWidget {
  final String serviceProviderUid;

  const Booking({super.key, required this.serviceProviderUid});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final double coverHeight = 160;
  final double profileHeight = 100;
  final DropdownController dropdownController = Get.put(DropdownController());
  final user = FirebaseAuth.instance.currentUser;
  late Future<Map<String, dynamic>> _providerData;
  List<Map<String, dynamic>> services = [];
  late Future<Map<String, dynamic>> carDetailsData;
  final logger = Logger();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  late double totalPrice;
  late String fullName;
  late String phoneNumber;
  late final String shopName;
  late final String shopAddress;
  late final List<String> allowedDaysOfWeek;
  late final int standardBookingsPerHour;
  Map<String, int> availableSlotsPerHour = {};
  Map<String, int> remainingSlots = {};

  @override
  void initState() {
    super.initState();
    _providerData =
        CategoriesService().fetchProviderByUid(widget.serviceProviderUid);
    loadServices();
    carDetailsData = fetchDefaultCarDetails();
    logger.i('carDetailsData: $carDetailsData');
    fetchTimeData();
    _fetchFullName();
    _fetchPhoneNumber();
    _fetchShopName();
    _fetchShopAddress();
    _fetchDaysOfTheWeek();
    _fetchNumberOfBookingsPerHour();
    fetchBookingsForDate(selectedDate);
  }

  Future<void> fetchTimeData() async {
    try {
      // Fetch the start and end time strings asynchronously
      String fetchedStartTime = await fetchStartTime();
      String fetchedEndTime = await fetchEndTime();

      // Convert the fetched strings to TimeOfDay
      setState(() {
        startTime = convertToTimeOfDay(fetchedStartTime);
        endTime = convertToTimeOfDay(fetchedEndTime);
      });
    } catch (e) {
      logger.e('Error fetching or converting time data: $e');
    }
  }

  Future<String> fetchStartTime() async {
    // Assuming _providerData is a Future<Map<String, dynamic>>
    Map<String, dynamic> providerData = await _providerData;

    String operationTime = providerData['operationTime'];
    String startTime = operationTime.split('-')[0].trim();

    logger.i('startTime', startTime);
    return startTime;
  }

  Future<String> fetchEndTime() async {
    // Assuming _providerData is a Future<Map<String, dynamic>>
    Map<String, dynamic> providerData = await _providerData;

    String operationTime = providerData['operationTime'];
    String endTime = operationTime.split('-')[1].trim();

    logger.i('endTime', endTime);
    return endTime;
  }

  // Function to convert time string to TimeOfDay
  TimeOfDay convertToTimeOfDay(String timeString) {
    try {
      // Split the time string into time and period (AM/PM)
      final timeParts = timeString.trim().split(' ');

      if (timeParts.length != 2) {
        logger.i(
            "Time string format should include both time and AM/PM, but found: $timeString");
        throw const FormatException(
            "Invalid time format: missing AM/PM or improper spacing.");
      }

      final hourMinute = timeParts[0].split(':');

      // Ensure both hour and minute are present
      if (hourMinute.length != 2) {
        logger.i(
            "Hour and minute should be separated by ':', but found: ${timeParts[0]}");
        throw const FormatException(
            "Invalid time format: missing ':' or incorrect hour/minute values.");
      }

      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      // Adjust for AM/PM
      String period = timeParts[1].toUpperCase();
      if (period == 'PM' && hour != 12) {
        hour += 12; // Convert PM times except 12 PM to 24-hour format
      } else if (period == 'AM' && hour == 12) {
        hour = 0; // Midnight case (12 AM)
      }

      // Return valid TimeOfDay object
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      logger.e("Error parsing time string '$timeString': $e");
      return TimeOfDay.now(); // Default to current time in case of an error
    }
  }

  String formatBookingDate(String date) {
    // Parse the date string
    DateTime parsedDate = DateTime.parse(date);
    // Format to a more readable format
    return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}"; // Change format as needed
  }

  // Convert TimeOfDay to formatted time string (e.g., "9:00 AM")
  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final time = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.jm().format(time); // 'jm' gives the '9:00 AM' format
  }

  Future<Map<String, dynamic>> fetchDefaultCarDetails() async {
    try {
      // Fetch default car details instead of all car details
      Map<String, dynamic> fetchedCarDetails = await BookingService()
          .fetchDefaultCarDetails(user!.uid); // Call the new function

      if (fetchedCarDetails.isEmpty) {
        logger.i('No default car found for this user.');
      } else {
        logger.i('Default Car Data: $fetchedCarDetails');
      }

      return fetchedCarDetails; // Return the fetched car details
    } catch (e) {
      logger.e('Error fetching car details: $e');
      return {}; // Return empty map in case of error
    }
  }

  // Load services and calculate total price
  void loadServices() async {
    List<Map<String, dynamic>> fetchedServices =
        await BookingService().fetchServices(widget.serviceProviderUid);
    setState(() {
      services = fetchedServices;
    });
  }

  Future<void> _fetchFullName() async {
    final fetchedFullName = await BookingService().fetchFullName();
    setState(() {
      fullName = fetchedFullName!;
    });
  }

  Future<void> _fetchShopName() async {
    final fetchedShopName = await BookingService()
        .fetchServiceProviderShopName(widget.serviceProviderUid);
    setState(() {
      shopName = fetchedShopName!;
    });
  }

  Future<void> _fetchDaysOfTheWeek() async {
    final fetchedDaysOfTheweek = await BookingService()
        .fetchAllowedDaysOfWeek(widget.serviceProviderUid);
    setState(() {
      allowedDaysOfWeek = fetchedDaysOfTheweek!;
    });
  }

  Future<void> _fetchShopAddress() async {
    final fetchedShopAddress = await BookingService()
        .fetchServiceProviderLocation(widget.serviceProviderUid);
    setState(() {
      shopAddress = fetchedShopAddress!;
      logger.i("ADDRESS", shopAddress);
    });
  }

  Future<void> _fetchPhoneNumber() async {
    final fetchedPhoneNumber = await BookingService().fetchPhoneNumber();
    setState(() {
      phoneNumber = fetchedPhoneNumber!;
    });
  }

  double calculateTotalPrice(List<String> selectedServices) {
    double total = 0.0;
    for (var service in selectedServices) {
      // Find the service in the list and add its price to the total
      var matchingService = services.firstWhere(
          (services) => services['name'] == service,
          orElse: () => {});
      if (matchingService.isNotEmpty) {
        total += matchingService['price'] ?? 0.0;
      }
    }
    return total;
  }

  Future<void> _fetchNumberOfBookingsPerHour() async {
    final fetchedNumberOfBookingsPerHour = await BookingService()
        .fetchServiceProviderNumberOfBookings(widget.serviceProviderUid);
    setState(() {
      standardBookingsPerHour = fetchedNumberOfBookingsPerHour!;
    });
  }

  Future<void> fetchBookingsForDate(DateTime date) async {
    Map<String, int> fetchedBookings = await BookingService()
        .fetchBookingsForDate(widget.serviceProviderUid, date);
    setState(() {
      availableSlotsPerHour = fetchedBookings;
    });
  }

  void navigateToCarDetails() async {
    // Navigate to the CarDetails screen and wait for the result
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CarDetails()),
    );
    // After returning from the CarDetails screen, fetch the updated car details
    setState(() {
      carDetailsData = fetchDefaultCarDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking',
            style: TextStyle(fontWeight: FontWeight.w900)),
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
              return const Center(child: Text('No data found'));
            }

            final providerData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  buildTopSection(providerData, top), // Pass provider data
                  buildShopName(providerData), // Pass provider data
                  const Padding(
                    padding: EdgeInsets.only(
                      right: 16.0,
                      left: 16,
                      top: 20,
                    ),
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  pickService(),
                  timeSelection(),
                  carDetails(),
                  submitButton(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildTopSection(Map<String, dynamic> providerData, double top) {
    double rating = providerData['totalRatings'] ?? 0;
    int numberOfRating = providerData['numberOfRatings'] ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: profileHeight / 2),
          child: buildCoverImage(providerData),
        ),
        Positioned(
          left: 20,
          top: top,
          child: buildProfileImage(providerData),
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
                  (index) => RatingWidget(
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

  Widget buildShopName(Map<String, dynamic> providerData) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                providerData['shopName'], // Use shopName from Booking
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.orange.shade900,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    providerData['location'],
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Colors.orange.shade900,
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    providerData['daysOfTheWeek'].join(', ') ??
                        'Operating Days',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.orange.shade900,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              providerData['serviceSpecialization']
                                      .join(', ') ??
                                  'Specialization',
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.visible,
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

  //Profile Image
  Widget buildProfileImage(Map<String, dynamic> data) => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: NetworkImage(data['profileImage'] ??
            'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
      );

  //Cover Image
  Widget buildCoverImage(Map<String, dynamic> data) => Container(
        color: Colors.grey,
        child: Image.network(
          data['coverImage'] ??
              'https://mewitti.com/wp-content/themes/miyazaki/assets/images/default-fallback-image.png',
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Checklist(
              options:
                  services.map((service) => service['name'] as String).toList(),
              hintText: 'Service Services',
              controller: dropdownController,
              onSelectionChanged: (selectedOptions) {},
            ),
          ],
        ),
      );

  Widget carDetails() => FutureBuilder<Map<String, dynamic>>(
        future: carDetailsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'No car details data found',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: navigateToCarDetails,
                    icon: const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Add Car Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final carData = snapshot.data!;
          logger.i('car Data', carData);
          final carDetails =
              carData.entries.first.value as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Car Details',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: navigateToCarDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30.0), // Rounded button
                            ),
                          ),
                          child: const Text(
                            'Edit Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                        'Brand', carDetails['brand'], Icons.directions_car),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                        'Model', carDetails['model'], Icons.model_training),
                    const SizedBox(height: 10),
                    _buildDetailRow('Year', carDetails['year']?.toString(),
                        Icons.calendar_today),
                    const SizedBox(height: 10),
                    _buildDetailRow('Fuel Type', carDetails['fuelType'],
                        Icons.local_gas_station),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                        'Color', carDetails['color'], Icons.color_lens),
                    const SizedBox(height: 10),
                    _buildDetailRow('Transmission',
                        carDetails['transmissionType'], Icons.settings),
                  ],
                ),
              ),
            ),
          );
        },
      );

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[100], // Light grey background for the row
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0, // Soft shadow effect
            offset: Offset(0, 2), // Shadow offset
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: Colors.orange.shade900), // Icon next to the label
              const SizedBox(width: 4), // Space between icon and label
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            value ?? 'N/A', // Display 'N/A' if value is null
            style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Submit Button
  Widget submitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
      child: ElevatedButton(
        onPressed: () async {
          Map<String, dynamic> fetchCarDetails = await carDetailsData;
          logger.i('Car Details: $fetchCarDetails');

          // Get the first key of the fetched car details
          String carKey = fetchCarDetails.keys.first;

          // Now access the nested car details using this key
          Map<String, dynamic> carDetails = fetchCarDetails[carKey] ?? {};

          // Collecting information from the fetched car details
          String brand = carDetails['brand'] ?? '';
          String model = carDetails['model'] ?? '';
          String year = carDetails['year']?.toString() ?? '';
          String fuelType = carDetails['fuelType'] ?? '';
          String color = carDetails['color'] ?? '';
          String transmission = carDetails['transmissionType'] ?? '';

          String bookingDate = formatBookingDate(selectedDate.toString());
          String bookingTime = formatTimeOfDay(selectedTime);

          // Assuming dropdownController.selectedOptions is a list of selected services
          List<String> selectedServices = dropdownController.selectedOptionList;

          // Validate the input
          String errorMessage = '';
          if (brand.isEmpty) errorMessage += 'Brand is required.\n';
          if (model.isEmpty) errorMessage += 'Model is required.\n';
          if (year.isEmpty) errorMessage += 'Year is required.\n';
          if (fuelType.isEmpty) errorMessage += 'Fuel Type is required.\n';
          if (color.isEmpty) errorMessage += 'Color is required.\n';
          if (transmission.isEmpty)
            errorMessage += 'Transmission is required.\n';
          if (selectedServices.isEmpty)
            errorMessage += 'Please select at least one service.\n';

          // Year validation
          if (year.isNotEmpty &&
              (int.tryParse(year) == null ||
                  int.parse(year) < 1886 ||
                  int.parse(year) > DateTime.now().year)) {
            errorMessage += 'Please enter a valid year.\n';
          }

          if (errorMessage.isNotEmpty) {
            Utils.showSnackBar(errorMessage);
            return; // Exit the method
          }

          // Update the total price
          setState(() {
            totalPrice = calculateTotalPrice(selectedServices);
          });

          try {
            // Fetch the service provider's existing remainingSlots from Firestore
            var docSnapshot = await FirebaseFirestore.instance
                .collection('automotiveShops_profile')
                .doc(widget.serviceProviderUid)
                .get();

            Map<String, dynamic>? data = docSnapshot.data();
            Map<String, Map<String, dynamic>> remainingSlots =
                Map<String, Map<String, dynamic>>.from(
                    data?['remainingSlots'] ?? {});

            // Fetch startTime, endTime, and numberOfBookingsPerHour from data
            String finalStartTime = formatTimeOfDay(startTime!);
            String finalEndTime = formatTimeOfDay(endTime!);
            int numberOfBookingsPerHour = data?['numberOfBookingsPerHour'] ?? 1;

            // Check if the booking date exists in remainingSlots
            if (!remainingSlots.containsKey(bookingDate)) {
              // If no slots for this date, generate the time slots for this day
              remainingSlots[bookingDate] = generateTimeSlots(
                  finalStartTime, finalEndTime, numberOfBookingsPerHour);
            }

            // Decrement the slot for the specific booking time
            if (remainingSlots[bookingDate]!.containsKey(bookingTime)) {
              if (remainingSlots[bookingDate]![bookingTime]! > 0) {
                remainingSlots[bookingDate]![bookingTime] =
                    remainingSlots[bookingDate]![bookingTime]! - 1;

                // Call your booking service to save the booking
                await BookingService().createBookingRequest(
                  carOwnerUid: user!.uid,
                  serviceProviderUid: widget.serviceProviderUid,
                  selectedService: selectedServices.join(', '),
                  bookingDate: bookingDate,
                  bookingTime: bookingTime,
                  carBrand: brand,
                  carModel: model,
                  carYear: year,
                  fuelType: fuelType,
                  color: color,
                  transmission: transmission,
                  createdAt: DateTime.now(),
                  status: 'pending',
                  phoneNumber: phoneNumber,
                  fullName: fullName,
                  totalPrice: totalPrice,
                  shopAddress: shopAddress,
                  shopName: shopName,
                );

                // Update the service provider's remainingSlots in Firestore
                await FirebaseFirestore.instance
                    .collection('automotiveShops_profile')
                    .doc(widget.serviceProviderUid)
                    .update({'remainingSlots': remainingSlots});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully Booked'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Show a success message
                logger.i('Booking confirmed successfully!');

                // Navigate to another page or reset the form
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavBar(),
                  ),
                );
              } else {
                // If no slots are available for the selected time, show an error
                Utils.showSnackBar(
                    'Selected time is fully booked. Please choose another time.');
                return;
              }
            } else {
              Utils.showSnackBar(
                  'Selected time is not available. Please choose another time.');
              return;
            }
          } catch (e) {
            // Handle any errors during booking submission
            logger.e('Error confirming booking: $e');
            Utils.showSnackBar('Failed to confirm booking. Please try again');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15), // Set the border radius to 15
          ),
          minimumSize: const Size(400, 45),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

// Helper function to generate time slots based on start and end times
  Map<String, int> generateTimeSlots(
      String startTime, String endTime, int standardBookingsPerHour) {
    Map<String, int> timeSlots = {};

    // Parse startTime and endTime into DateTime objects
    DateTime start = _parseTime(startTime);
    DateTime end = _parseTime(endTime);

    // Generate time slots in hourly intervals
    while (start.isBefore(end)) {
      String formattedTime = _formatTime(start);
      timeSlots[formattedTime] =
          standardBookingsPerHour; // Assign the standard bookings per hour

      // Increment the time by 1 hour
      start = start.add(const Duration(hours: 1));
    }

    // Ensure the last time slot (if endTime is exactly at the hour) is included
    if (start.isAtSameMomentAs(end)) {
      String formattedTime = _formatTime(start);
      timeSlots[formattedTime] = standardBookingsPerHour;
    }

    return timeSlots;
  }

// Helper function to parse time string into DateTime
  DateTime _parseTime(String time) {
    // Example format: '9:00 AM' or '4:00 PM'
    final format = DateFormat.jm(); // 'jm' stands for 'hour:minute AM/PM'
    return format.parse(time);
  }

// Helper function to format DateTime object to '9:00 AM' format
  String _formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  Widget timeSelection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date and Time',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 35,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DatePickerDisplay(
                          initialDate: selectedDate,
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          onDateSelected: (date) async {
                            setState(() {
                              selectedDate = date;
                            });
                            // Fetch remaining slots for the selected date
                            try {
                              remainingSlots = await fetchRemainingSlots(
                                selectedDate,
                                widget.serviceProviderUid,
                              );
                              logger.i(
                                  'Remaining slots fetched: $remainingSlots');
                            } catch (e) {
                              logger.e('Error fetching slots: $e');
                            }
                          },
                          allowedDaysOfWeek: allowedDaysOfWeek,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 35,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TimePickerDisplay(
                          initialTime: selectedTime,
                          textStyle: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          startTime: startTime!,
                          endTime: endTime!,
                          onTimeSelected: (time) {
                            setState(() {
                              selectedTime = _snapToNearestHour(time);
                            });
                          },
                          availableSlots: remainingSlots,
                          standardBookingsPerHour: standardBookingsPerHour,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Function to snap TimeOfDay to the nearest hour
  TimeOfDay _snapToNearestHour(TimeOfDay time) {
    int roundedHour = time.minute >= 30 ? time.hour + 1 : time.hour;
    return TimeOfDay(hour: roundedHour % 24, minute: 0); // Ensure hour is valid
  }

  Future<Map<String, int>> fetchRemainingSlots(
      DateTime date, String serviceProviderUid) async {
    // Format the date to M/d/yyyy
    String formattedDate = "${date.day}/${date.month}/${date.year}";

    logger.i('Fetching remaining slots for date: $formattedDate');

    var docSnapshot = await FirebaseFirestore.instance
        .collection('automotiveShops_profile')
        .doc(serviceProviderUid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      Map<String, Map<String, dynamic>>? remainingSlots =
          Map<String, Map<String, dynamic>>.from(data?['remainingSlots'] ?? {});

      // Log the fetched remaining slots for inspection
      logger.i('Remaining slots from Firestore: $remainingSlots');

      // Check if the formattedDate exists in remainingSlots
      if (remainingSlots.containsKey(formattedDate)) {
        Map<String, int>? slotsForDate = remainingSlots[formattedDate]
            ?.map((key, value) => MapEntry(key, value as int));
        logger.i('Slots for date: $slotsForDate');
        setState(() {
          remainingSlots =
              (slotsForDate ?? {}).cast<String, Map<String, dynamic>>();
        });
        return slotsForDate ?? {};
      } else {
        logger.i('No slots found for the date: $formattedDate');
        return {}; // Return empty map if no slots found for the date
      }
    } else {
      logger.e('Profile not found for UID: $serviceProviderUid');
      throw Exception('Profile not found');
    }
  }
}
