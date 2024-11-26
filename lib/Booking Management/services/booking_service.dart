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

  // Fetch default car details
  Future<Map<String, dynamic>> fetchDefaultCarDetails(
      String carOwnerUid) async {
    try {
      if (carOwnerUid.isEmpty) {
        logger.e('Invalid carOwnerUid');
        return {};
      }

      // Reference to the car details collection for the specific car owner
      var carDetailsCollection = firestore
          .collection('car_owner_profile')
          .doc(carOwnerUid)
          .collection('carDetails');

      // Query to fetch the default car (where isDefault is true)
      final snapshot = await carDetailsCollection
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      logger.i('Car details snapshot for user: $carOwnerUid');

      if (snapshot.docs.isEmpty) {
        logger.i('No default car found for this user.');
        return {};
      }

      // Map to hold car details
      Map<String, dynamic> carDetailsMap = {};

      // Fetch the first document from the snapshot (default car)
      final doc = snapshot.docs.first;
      final carDetails = CarDetailsModel.fromMap(doc.data());

      // Add the default car details to the map with its document ID
      carDetailsMap[doc.id] = carDetails.toMap();

      logger.i('Default car details fetched successfully.');
      return carDetailsMap; // Return the map containing the default car's details
    } catch (error) {
      logger.e('Error fetching default car details: $error');
      return {}; // Return an empty map if there's an error
    }
  }

  //fetch full name of the car owner
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
          return null;
        }
      } catch (e) {
        logger.e('Error fetching user profile: $e');
        return null;
      }
    }
    return null;
  }

  //Fetch phone number of the car owner
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
          return null;
        }
      } catch (e) {
        logger.e('Error fetching user profile: $e');
        return null;
      }
    }
    return null;
  }

// Fetch shop name of the service provider
  Future<List<String>?> fetchAllowedDaysOfWeek(
      String serviceProviderUid) async {
    try {
      final doc = await firestore
          .collection('automotiveShops_profile')
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
          return null;
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
      return [];
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
              'automotiveShops_profile')
          .doc(serviceProviderUid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          // Extract shopName
          final String shopName = data['shopName'] ?? '';
          logger.i('SHOPNAME', shopName);
          return shopName;
        } else {
          logger.i(
              'No profile data found for service provider: $serviceProviderUid');
          return null;
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
              'automotiveShops_profile')
          .doc(serviceProviderUid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          // Extract location
          final String location = data['location'] ?? '';
          return location;
        } else {
          logger.i(
              'No profile data found for service provider: $serviceProviderUid');
          return null;
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
              'automotiveShops_profile')
          .doc(serviceProviderUid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          // Extract shopName
          final int numberOfBookingsPerHour = data['numberOfBookingsPerHour'];
          logger.i('numberOfBookings', numberOfBookingsPerHour);
          return numberOfBookingsPerHour;
        } else {
          logger.i(
              'No profile data found for service provider: $serviceProviderUid');
          return null;
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
  Future<List<BookingModel>> fetchExistingBookings(
      String serviceProviderId) async {
    QuerySnapshot bookingSnapshot = await firestore
        .collection('bookings')
        .where('serviceProviderUid', isEqualTo: serviceProviderId)
        .get();

    // Cast the data to Map<String, dynamic> before passing to fromMap
    return bookingSnapshot.docs.map((doc) {
      final data = doc.data()
          as Map<String, dynamic>?;
      if (data != null) {
        return BookingModel.fromMap(data);
      } else {
        throw Exception('Booking data is null for document: ${doc.id}');
      }
    }).toList();
  }

  Future<Map<String, int>> fetchBookingsForDate(
      String serviceProviderUid, DateTime date) async {
    return await FirebaseFirestore.instance
        .collection('bookings')
        .where('serviceProviderUid', isEqualTo: serviceProviderUid)
        .where('date', isEqualTo: date.toIso8601String())
        .get()
        .then((querySnapshot) {
      Map<String, int> bookingsPerHour = {};
      for (var doc in querySnapshot.docs) {
        String timeSlot = doc['timeSlot'];
        bookingsPerHour[timeSlot] = (bookingsPerHour[timeSlot] ?? 0) + 1;
      }
      return bookingsPerHour;
    });
  }
}
