import 'package:autocare_carowners/Booking%20Management/models/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../ProfileManagement/models/car_owner_car_details_model.dart';

class BookingService {
  late final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference carDetailsCollection;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();

  //Fetch services offered by the service provider
  Future<List<Map<String, dynamic>>> fetchServices(
      String serviceProviderUid) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('services')
          .where('uid', isEqualTo: serviceProviderUid)
          .get();

      // Extract the details from each service
      List<Map<String, dynamic>> services = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      logger
          .i('Services fetched successfully for provider: $serviceProviderUid');
      return services;
    } catch (e) {
      logger.e('Error fetching services: $e');
      return [];
    }
  }

  // Fetch car owner details
  Future<Map<String, dynamic>> fetchCarOwnerDetails(String carOwnerUid) async {
    try {
      if (carOwnerUid.isEmpty) {
        logger.e('Invalid carOwnerUid');
        return {};
      }

      carDetailsCollection = firestore
          .collection('car_owner_profile')
          .doc(carOwnerUid)
          .collection('carDetails');

      final snapshot = await carDetailsCollection.get();
      logger.i('Car details snapshot for user: $carOwnerUid');

      if (snapshot.docs.isEmpty) {
        logger.i('No car details found for this user.');
        return {};
      }

      Map<String, dynamic> carDetailsMap = {};

      for (var doc in snapshot.docs) {
        final carDetails =
            CarDetailsModel.fromMap(doc.data() as Map<String, dynamic>);
        carDetailsMap[doc.id] = carDetails.toMap();
      }

      logger.i('Car details fetched successfully.');
      return carDetailsMap;
    } catch (error) {
      logger.e('Error fetching car details: $error');
      return {};
    }
  }

  Future<String?> fetchFullName() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc =
            await firestore.collection('car_owner_profile').doc(user.uid).get();
        final data = doc.data();

        if (data != null) {
          // Extract only firstName and lastName from the document data
          final String firstName = data['firstName'] ?? '';
          final String lastName = data['lastName'] ?? '';

          // Return the full name concatenated
          return '$firstName $lastName';
        } else {
          logger.i('No full name for: ${user.uid}');
          return null; // Return null if no data found
        }
      } catch (e) {
        logger.e('Error fetching user profile: $e');
        return null;
      }
    }
    return null; // Return null if user is not logged in
  }

  Future<String?> fetchPhoneNumber() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc =
            await firestore.collection('car_owner_profile').doc(user.uid).get();
        final data = doc.data();

        if (data != null) {
          // Extract only firstName and lastName from the document data
          final String carOwnerPhoneNumber = data['phoneNumber'] ?? '';

          // Return the full name concatenated
          return carOwnerPhoneNumber;
        } else {
          logger.i('No profile data found for user: ${user.uid}');
          return null; // Return null if no data found
        }
      } catch (e) {
        logger.e('Error fetching user profile: $e');
        return null;
      }
    }
    return null; // Return null if user is not logged in
  }

// Fetch shop name of the service provider
  Future<List<String>?> fetchAllowedDaysOfWeek(
      String serviceProviderUid) async {
    try {
      final doc = await firestore
          .collection(
              'automotiveShops_profile') // Adjust the collection name if necessary
          .doc(serviceProviderUid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          // Extract daysOfTheWeek as a List<String>
          final List<String>? allowedDaysOfTheWeek =
              List<String>.from(data['daysOfTheWeek'] ?? []);

          // Convert allowed days to the desired format
          return convertToFullWeekDays(allowedDaysOfTheWeek);
        } else {
          logger.i(
              'No profile data found for service provider: $serviceProviderUid');
          return null; // Return null if no data found
        }
      } else {
        logger.i('No profile found for service provider: $serviceProviderUid');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching service provider days of the week: $e');
      return null;
    }
  }

// Convert the allowed days of the week to full week format
  List<String> convertToFullWeekDays(List<String>? allowedDays) {
    // Define the full week days
    List<String> fullWeekDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    // If allowedDays is null or empty, return an empty list
    if (allowedDays == null || allowedDays.isEmpty) {
      return []; // Return an empty list if none are allowed
    }

    // Filter to include only the allowed days in the full week
    return fullWeekDays.where((day) => allowedDays.contains(day)).toList();
  }

  // Fetch shop name of the service provider
  Future<String?> fetchServiceProviderShopName(
      String serviceProviderUid) async {
    try {
      final doc = await firestore
          .collection(
              'automotiveShops_profile') // Adjust the collection name if necessary
          .doc(serviceProviderUid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          // Extract shopName
          final String shopName = data['shopName'] ?? '';
          logger.i('SHOPNAME', shopName);
          return shopName; // Return the shop name
        } else {
          logger.i(
              'No profile data found for service provider: $serviceProviderUid');
          return null; // Return null if no data found
        }
      } else {
        logger.i('No profile found for service provider: $serviceProviderUid');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching service provider shop name: $e');
      return null;
    }
  }

  // Fetch location of the service provider
  Future<String?> fetchServiceProviderLocation(
      String serviceProviderUid) async {
    try {
      final doc = await firestore
          .collection(
              'automotiveShops_profile') // Adjust the collection name if necessary
          .doc(serviceProviderUid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          // Extract location
          final String location = data['location'] ?? '';
          return location; // Return the location
        } else {
          logger.i(
              'No profile data found for service provider: $serviceProviderUid');
          return null; // Return null if no data found
        }
      } else {
        logger.i('No profile found for service provider: $serviceProviderUid');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching service provider location: $e');
      return null;
    }
  }

  // Create a booking request
  Future<String> createBookingRequest({
    required String carOwnerUid,
    required String serviceProviderUid,
    required String selectedService,
    required String bookingDate,
    required String bookingTime,
    required String carBrand,
    required String carModel,
    required String carYear,
    required String fuelType,
    required String color,
    required String transmission,
    required DateTime createdAt,
    required String status,
    required String? phoneNumber,
    required String fullName,
    required double totalPrice,
    required String shopName,
    required String shopAddress,
  }) async {
    try {
      // Create a booking ID using Firestore's document ID generation
      String bookingId = firestore.collection('bookings').doc().id;

      // Create the new Booking Model
      BookingModel newBooking = BookingModel(
        carOwnerUid: carOwnerUid,
        serviceProviderUid: serviceProviderUid,
        bookingId: bookingId,
        selectedService: [selectedService],
        bookingTime: bookingTime,
        carBrand: carBrand,
        carModel: carModel,
        carYear: carYear,
        fuelType: fuelType,
        color: color,
        transmission: transmission,
        createdAt: createdAt,
        bookingDate: bookingDate,
        phoneNumber: phoneNumber,
        fullName: fullName,
        totalPrice: totalPrice,
        status: status,
        shopName: shopName,
        shopAddress: shopAddress,
        isFeedbackSubmitted: false,
      );

      // Store the booking in Firestore
      await firestore
          .collection('bookings')
          .doc(bookingId)
          .set(newBooking.toMap());

      logger.i('Booking request created successfully: $bookingId');
      return 'Booking added successfully';
    } catch (e) {
      logger.e('Failed to add booking: $e');
      return 'Failed to add booking: $e';
    }
  }

  // Fetch shop name of the service provider
  Future<int?> fetchServiceProviderNumberOfBookings(
      String serviceProviderUid) async {
    try {
      final doc = await firestore
          .collection(
              'automotiveShops_profile') // Adjust the collection name if necessary
          .doc(serviceProviderUid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          // Extract shopName
          final int numberOfBookingsPerHour = data['numberOfBookingsPerHour'];
          logger.i('numberOfBookings', numberOfBookingsPerHour);
          return numberOfBookingsPerHour; // Return the shop name
        } else {
          logger.i(
              'No profile data found for service provider: $serviceProviderUid');
          return null; // Return null if no data found
        }
      } else {
        logger.i('No profile found for service provider: $serviceProviderUid');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching service provider shop name: $e');
      return null;
    }
  }

  // Fetch existing bookings for a specific service provider
  // Fetch existing bookings for a specific service provider
  Future<List<BookingModel>> fetchExistingBookings(
      String serviceProviderId) async {
    QuerySnapshot bookingSnapshot = await firestore
        .collection('bookings')
        .where('serviceProviderUid', isEqualTo: serviceProviderId)
        .get();

    // Cast the data to Map<String, dynamic> before passing to fromMap
    return bookingSnapshot.docs.map((doc) {
      final data = doc.data()
          as Map<String, dynamic>?; // Safely cast to Map<String, dynamic>
      if (data != null) {
        return BookingModel.fromMap(data);
      } else {
        throw Exception('Booking data is null for document: ${doc.id}');
      }
    }).toList();
  }

  Future<Map<String, int>> fetchBookingsForDate(String serviceProviderUid, DateTime date) async {
    // Query the bookings from your database based on service provider ID and the selected date
    // Return a map where the key is the hour of the day and the value is the number of bookings
    // Example: {'9AM': 3, '10AM': 4}
    // Assume 'bookingsPerHour' is the limit of bookings per hour
    return await FirebaseFirestore.instance
        .collection('bookings')
        .where('serviceProviderUid', isEqualTo: serviceProviderUid)
        .where('date', isEqualTo: date.toIso8601String())
        .get()
        .then((querySnapshot) {
      Map<String, int> bookingsPerHour = {};
      for (var doc in querySnapshot.docs) {
        // Assuming you store time in 'timeSlot' field as a string (e.g., '9AM', '10AM')
        String timeSlot = doc['timeSlot'];
        bookingsPerHour[timeSlot] = (bookingsPerHour[timeSlot] ?? 0) + 1;
      }
      return bookingsPerHour;
    });
  }
}
