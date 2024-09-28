import 'package:autocare_carowners/Booking%20Management/services/booking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pannable_rating_bar/flutter_pannable_rating_bar.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/checklist.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/timeSelection.dart';
import 'package:autocare_carowners/Booking%20Management/widgets/date_selection.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../Authentication/Widgets/snackBar.dart';
import '../../Service Directory Management/services/categories_service.dart';

class Booking extends StatefulWidget {
  final String serviceProviderUid;

  const Booking({super.key, required this.serviceProviderUid});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final double coverHeight = 220;
  final double profileHeight = 130;
  final DropdownController dropdownController = Get.put(DropdownController());
  final user = FirebaseAuth.instance.currentUser;
  late Future<Map<String, dynamic>> _providerData;
  List<Map<String, dynamic>> services = [];
  late Future<Map<String, dynamic>> carOwnerData;
  final logger = Logger();
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime selectedDate = DateTime.now();
  late double totalPrice;
  late String fullName;
  late String phoneNumber;

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
        logger.i("Time string format should include both time and AM/PM, but found: $timeString");
        throw const FormatException("Invalid time format: missing AM/PM or improper spacing.");
      }

      final hourMinute = timeParts[0].split(':');

      // Ensure both hour and minute are present
      if (hourMinute.length != 2) {
        logger.i("Hour and minute should be separated by ':', but found: ${timeParts[0]}");
        throw const FormatException("Invalid time format: missing ':' or incorrect hour/minute values.");
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

  String formatBookingTime(TimeOfDay time) {
    final hours = time.hour % 12 == 0 ? 12 : time.hour % 12; // Convert 0 and 12 to 12
    final minutes = time.minute.toString().padLeft(2, '0'); // Ensure two-digit minutes
    final period = time.hour >= 12 ? 'PM' : 'AM'; // Determine AM/PM
    return "$hours:$minutes $period"; // Format as needed
  }

  @override
  void initState() {
    super.initState();
    _providerData =
        CategoriesService().fetchProviderByUid(widget.serviceProviderUid);
    loadServices();
    carOwnerData = fetchCarDetails();
    fetchTimeData();
    _fetchFullName();
    _fetchPhoneNumber();
  }
  Future<Map<String, dynamic>> fetchCarDetails() async {
    try {
      Map<String, dynamic> fetchedCarDetails = await BookingService().fetchCarOwnerDetails(user!.uid);

      logger.i('Car Owner Data: $fetchedCarDetails');
      return fetchedCarDetails;
    } catch (e) {
      logger.e('Error fetching car details: $e');
      return {};
    }
  }

  // Load services and calculate total price
  void loadServices() async {
    List<Map<String, dynamic>> fetchedServices = await BookingService().fetchServices(widget.serviceProviderUid);
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
      var matchingService = services.firstWhere((services) => services['name'] == service, orElse: () => {});
      if (matchingService.isNotEmpty) {
        total += matchingService['price'] ?? 0.0;
      }
    }
    return total;
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    fuelTypeController.dispose();
    colorController.dispose();
    transmissionController.dispose();
    super.dispose();
  }

  bool isEditing = false;

  // TextEditingController to handle car details input
  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController yearController;
  late TextEditingController fuelTypeController;
  late TextEditingController colorController;
  late TextEditingController transmissionController;

  @override
  Widget build(BuildContext context) {
    final double top = coverHeight - profileHeight / 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
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
                    padding:
                        EdgeInsets.only(right: 16.0,left: 16, top: 20,),
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
    // Assuming buildTopSection uses serviceName and shopName
    double rating = 3;
    int numberOfRating = 33;

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
                   Icon(Icons.location_on, color: Colors.orange.shade900, size: 15,),
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
                   Icon(Icons.calendar_month, color: Colors.orange.shade900, size: 15,),
                  const SizedBox(width: 4),
                  Text(
                    providerData['daysOfTheWeek'].join(', ') ??
                        'Operating Days',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   Icon(Icons.check, color: Colors.orange.shade900, size: 15,),
                  const SizedBox(width: 4),
                  Text(
                    providerData['serviceSpecialization'].join(', ') ??
                        'Specialization',
                    style: const TextStyle(fontSize: 15),
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
        backgroundImage:
            NetworkImage(data['profileImage'] ?? 'default_profile_image_url'),
      );

  //Cover Image
  Widget buildCoverImage(Map<String, dynamic> data) => Container(
        color: Colors.grey,
        child: Image.network(
          data['coverImage'] ?? 'default_cover_image_url',
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
      future: carOwnerData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No car owner data found'));
        }

        final carData = snapshot.data!;
        logger.i('car Data', carData);
        final carDetails = carData.entries.first.value as Map<String, dynamic>;

        // Initialize controllers with current car data
        brandController = TextEditingController(
            text: carDetails['brand'] as String? ?? '');
        modelController = TextEditingController(
            text: carDetails['model'] as String? ?? '');
        yearController = TextEditingController(
            text: carDetails['year']?.toString() ?? '');
        fuelTypeController = TextEditingController(
            text: carDetails['fuelType'] as String? ?? '');
        colorController = TextEditingController(
            text: carDetails['color'] as String? ?? '');
        transmissionController = TextEditingController(
            text: carDetails['transmissionType'] as String? ?? '');

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Car Details',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              TextField(
                controller: fuelTypeController,
                decoration: const InputDecoration(labelText: 'Fuel Type'),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: transmissionController,
                decoration: const InputDecoration(labelText: 'Transmission'),
              ),
            ],
          ),
        );
      });

  Widget carDetailRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Display text field if editing, otherwise just display the value
          isEditing
              ? Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Enter $label',
                    ),
                  ),
                )
              : Text(controller.text),
        ],
      ),
    );
  }

  //Submit Button
  Widget submitButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
      child:
      ElevatedButton(
      onPressed: () async {
        // Collecting information from the input fields and selected services
        String brand = brandController.text;
        String model = modelController.text;
        String year = yearController.text;
        String fuelType = fuelTypeController.text;
        String color = colorController.text;
        String transmission = transmissionController.text;
        String bookingDate = formatBookingDate(selectedDate.toString()); // Adjust as needed
        String bookingTime = formatBookingTime(selectedTime);

        // Assuming dropdownController.selectedOptions is a list of selected services
        List<String> selectedServices = dropdownController.selectedOptionList;

        // Validate the input
        if (brand.isEmpty ||
            model.isEmpty ||
            year.isEmpty ||
            fuelType.isEmpty ||
            color.isEmpty ||
            transmission.isEmpty ||
            selectedServices.isEmpty) {
          // Show an error message if validation fails
          Utils.showSnackBar('Please complete the details');
          return; // Exit the method
        }

        // Update the total price
        setState(() {
          totalPrice = calculateTotalPrice(selectedServices);
        });

        try {
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
              totalPrice: totalPrice
          );


          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully Booked'),
                backgroundColor: Colors.green,
              ),
          );
          // Show a success message
          logger.i('Booking confirmed successfully!');
          // Optionally, you can navigate to another page or reset the form
          Navigator.pop(context); // This will go back to the previous page
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
            borderRadius: BorderRadius.circular(15), // Set the border radius to 15
          ),
          minimumSize: const Size(400, 45),
        ),
        child: const Text('Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),),
      ),
    );
  }

  Widget timeSelection() => Padding(
    padding: const EdgeInsets.all(20.0),
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
                            vertical: 15.0, horizontal: 35),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DatePickerDisplay(
                          initialDate: selectedDate,
                          textStyle: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          onDateSelected: (date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 35),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: TimePickerDisplay(
                          initialTime: selectedTime,
                          textStyle: const TextStyle(
                              fontSize: 15, color: Colors.black),
                          startTime: startTime!,
                          endTime: endTime!,
                          onTimeSelected: (time) {
                            setState(() {
                              selectedTime = time;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    ),
  );
}
