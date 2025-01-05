import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../Booking Management/models/booking_model.dart';

class CarOwnerBookingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();

  Future<List<BookingModel>> fetchBookings() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      logger.i('USERUID: ${currentUser.uid}');

      QuerySnapshot snapshot = await _firestore
          .collection('bookings')
          .where('carOwnerUid', isEqualTo: currentUser.uid)
          .get();

      List<BookingModel> bookings = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>?; // Safely cast
            if (data == null) {
              logger.w('Document data is null for doc ID: ${doc.id}');
              return null;
            }
            return BookingModel.fromMap(data);
          })
          .where((booking) => booking != null)
          .toList()
          .cast<BookingModel>();

      logger.i(
          'Fetched ${bookings.length} booking requests for car owner: ${currentUser.uid}');
      return bookings;
    } catch (e) {
      logger.e('Error fetching bookings: $e');
      rethrow;
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      final bookingRef = _firestore.collection('bookings').doc(bookingId);
      await bookingRef.delete();
      logger.i('Successfully deleted booking with ID: $bookingId');
    } catch (e) {
      logger.e('Error deleting booking: $e');
      rethrow;
    }
  }
}
