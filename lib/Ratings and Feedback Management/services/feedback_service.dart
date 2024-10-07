import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart'; // Import the logger package
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger(); // Initialize the logger

  Future<String> submitFeedback({
    required String bookingId,
    required String serviceProviderUid,
    required int rating,
    required String comment,
    required String carOwnerId,
    required String feedbackerName,
  }) async {
    try {
      //Generate feedback ID
      String feedbackId = _firestore.collection("feedback").doc().id;

      //Create a new feedback object
      FeedbackModel newFeedback = FeedbackModel(
          feedbackId: feedbackId,
          bookingId: bookingId,
          serviceProviderUid: serviceProviderUid,
          carOwnerId: carOwnerId,
          rating: rating,
          comment: comment,
          timestamp: DateTime.now(),
          feedbackerName: feedbackerName,
      );

      //Store the feedback in the "feedback" collection
      await _firestore.collection("feedback").doc(feedbackId).set(newFeedback.toMap());

      //Get current total rating and number of ratings for the service provider
      DocumentSnapshot serviceProviderSnapshot = await _firestore
          .collection('automotiveShops_profile')
          .doc(serviceProviderUid)
          .get();

      // Ensure the document exists and cast the data to a Map<String, dynamic>
      if (!serviceProviderSnapshot.exists) {
        throw Exception('Service provider not found');
      }

      Map<String, dynamic> serviceProviderData = serviceProviderSnapshot.data() as Map<String, dynamic>;
      logger.i('Service provider data: $serviceProviderData');

      double currentTotalRating = serviceProviderData['totalRatings'] ?? 0.0;
      int currentNumberOfRatings = serviceProviderData['numberOfRatings'] ?? 0;

      //Calculate new total rating and number of ratings
      double newTotalRating = currentTotalRating + rating;
      int newNumberOfRatings = currentNumberOfRatings + 1;

      // double newAverageRating = newTotalRating / newNumberOfRatings;

      // Step 6: Update the service provider's rating and number of ratings
      await _firestore.collection('automotiveShops_profile').doc(serviceProviderUid).update({
        'totalRatings': newTotalRating,
        'numberOfRatings': newNumberOfRatings,
      });

      // Update the booking document to set isFeedbackSubmitted to true
      await _firestore.collection('bookings').doc(bookingId).update({
        'isFeedbackSubmitted': true,
      });

      return 'Feedback submitted successfully and ratings updated';
    } catch (e) {
      logger.e('Error submitting feedback: $e');
      return 'Failed to submit feedback: $e';
    }
  }

  // Check if feedback has already been submitted
  Future<bool> isFeedbackSubmitted(String bookingId, String carOwnerId) async {
    try {
      QuerySnapshot feedbackSnapshot = await _firestore
          .collection('feedback')
          .where('bookingId', isEqualTo: bookingId)
          .where('carOwnerId', isEqualTo: carOwnerId)
          .get();

      if (feedbackSnapshot.docs.isNotEmpty) {
        var feedback = feedbackSnapshot.docs.first;
        return (feedback['isSubmitted'] ?? false) == true;  // Check if feedback was submitted
      }
      return false;
    } catch (e) {
      logger.i('Error checking feedback: $e');
      return false;
    }
  }

  Stream<List<FeedbackModel>> fetchFeedbackForProvider(String serviceProviderUid) {
    return _firestore
        .collection('feedback')
        .where('serviceProviderUid', isEqualTo: serviceProviderUid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((e) {
      logger.e('Error fetching feedback for provider $serviceProviderUid: $e'); // Log errors while fetching feedback
    });
  }

  Future<double> calculateAverageRating(String serviceProviderId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('feedback')
          .where('serviceProviderUid', isEqualTo: serviceProviderId)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      double totalRating = 0;
      int count = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        totalRating += doc['rating'];
      }

      return totalRating / count;
    } catch (e) {
      logger.e('Error calculating average rating for provider $serviceProviderId: $e'); // Log errors while calculating average rating
      return 0; // Return 0 in case of error
    }
  }

  Future<String?> fetchFullName(String carOwnerId) async {
      try {
        final doc = await _firestore
            .collection('car_owner_profile')
            .doc(carOwnerId)
            .get();
        final data = doc.data();

        if (data != null) {
          // Extract only firstName and lastName from the document data
          final String firstName = data['firstName'] ?? '';
          final String lastName = data['lastName'] ?? '';

          // Return the full name concatenated
          return '$firstName $lastName';
        } else {
          logger.i('No full name for: $carOwnerId');
          return null; // Return null if no data found
        }
      } catch (e) {
        logger.e('Error fetching user profile: $e');
        return null;
      }
    }

  Future<Map<String, dynamic>> fetchRatings(String serviceProviderUid) async {
    final feedbacks = <FeedbackModel>[];
    double totalRating = 0.0;
    int numberOfRatings = 0;

    QuerySnapshot snapshot = await _firestore
        .collection('feedback')
        .where('serviceProviderUid', isEqualTo: serviceProviderUid)
        .get();

    for (var doc in snapshot.docs) {
      final feedback = FeedbackModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      feedbacks.add(feedback);
      totalRating += feedback.rating;
      numberOfRatings += 1;
    }

    double averageRating = numberOfRatings > 0 ? totalRating / numberOfRatings : 0.0;

    return {
      'totalRating': averageRating,
      'numberOfRatings': numberOfRatings,
    };
  }
  }
