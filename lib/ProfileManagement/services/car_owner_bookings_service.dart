import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../Booking Management/models/booking_model.dart';

class CarOwnerBookingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();

  // Fetch bookings for the current car owner
  Future<List<BookingModel>> fetchBookings() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Log the current user UID
      logger.i('USERUID: ${currentUser.uid}');

      // Fetch bookings where 'carOwnerUid' matches the current user's UID
      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('carOwnerUid', isEqualTo: currentUser.uid)
          .get();

      // Map the documents to BookingModel
      List<BookingModel> bookings = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?; // Safely cast
        if (data == null) {
          logger.w('Document data is null for doc ID: ${doc.id}');
          return null;  // Handle the null case, if needed
        }
        return BookingModel.fromMap(data); // Safely map data
      }).where((booking) => booking != null).toList()
          .cast<BookingModel>(); // Ensure non-null list

      // Log the fetched bookings
      logger.i('Fetched ${bookings.length} booking requests for car owner: ${currentUser.uid}');
      return bookings;
    } catch (e) {
      // Log any error encountered during the process
      logger.e('Error fetching bookings: $e');
      rethrow;
    }
  }
}
