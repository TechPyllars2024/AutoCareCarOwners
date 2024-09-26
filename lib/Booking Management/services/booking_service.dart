import 'package:autocare_carowners/Booking%20Management/models/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../ProfileManagement/models/car_owner_car_details_model.dart';

class BookingService {
  late final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference carDetailsCollection;
  final logger = Logger();

  //Fetch services offered by the service provider
  Future<List<Map<String, dynamic>>> fetchServices(String serviceProviderUid) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('services')
          .where('uid', isEqualTo: serviceProviderUid)
          .get();

      // Extract the details from each service
      List<Map<String, dynamic>> services = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      logger.i('Services fetched successfully for provider: $serviceProviderUid');
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
        final carDetails = CarDetailsModel.fromMap(doc.data() as Map<String, dynamic>);
        carDetailsMap[doc.id] = carDetails.toMap();
      }

      logger.i('Car details fetched successfully.');
      return carDetailsMap;
    } catch (error) {
      logger.e('Error fetching car details: $error');
      return {};
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
      );

      // Store the booking in Firestore
      await firestore.collection('bookings').doc(bookingId).set(newBooking.toMap());

      logger.i('Booking request created successfully: $bookingId');
      return 'Booking added successfully';
    } catch (e) {
      logger.e('Failed to add booking: $e');
      return 'Failed to add booking: $e';
    }
  }
}
