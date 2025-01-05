import 'dart:async';
import 'package:autocare_carowners/ProfileManagement/services/car_owner_bookings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../Booking Management/models/booking_model.dart';
import '../../Ratings and Feedback Management/screens/feedback_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key, this.child});

  final Widget? child;

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final Logger logger = Logger();
  List<BookingModel> bookings = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      if (mounted) _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    try {
      List<BookingModel> carOwnerBookings =
          await CarOwnerBookingsService().fetchBookings();
      logger.i('BOOKINGS', carOwnerBookings);
      setState(() {
        bookings = carOwnerBookings;
        isLoading = false;
      });
    } catch (e) {
      logger.i('Error loading bookings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> cancelBooking(
      String bookingId, String shopId, String date, String time) async {
    try {
      CarOwnerBookingsService bookingsService = CarOwnerBookingsService();

      await bookingsService.deleteBooking(bookingId);

      DocumentReference shopRef = FirebaseFirestore.instance
          .collection('automotiveShops_profile')
          .doc(shopId);

      DocumentSnapshot snapshot = await shopRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> shopData = snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> remainingSlots = shopData['remainingSlots'] ?? {};

        if (remainingSlots.containsKey(date) &&
            remainingSlots[date] is Map<String, dynamic>) {
          Map<String, dynamic> timeSlots = remainingSlots[date];

          if (timeSlots.containsKey(time)) {
            int currentSlots = timeSlots[time] as int;
            timeSlots[time] = currentSlots + 1; // Increment remaining slots

            await shopRef.update({
              'remainingSlots': remainingSlots,
            });
          }
        }

        setState(() {
          bookings.removeWhere((b) => b.bookingId == bookingId);
        });

        // Show a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking Cancelled Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle errors, if any
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel booking'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showBookingDetailsModal(List<BookingModel> bookings) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            children: bookings.map((booking) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Service: ${booking.selectedService.join(', ')}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${booking.bookingDate}, ${booking.bookingTime}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.php,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking.totalPrice.toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.store,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking.shopName!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking.shopAddress!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.directions_car,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${booking.carBrand} ${booking.carModel} Year: ${booking.carYear}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.local_gas_station,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking.fuelType,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.settings,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking.transmission,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Display status if currently processing or loading
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Status: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Default color
                                ),
                              ),
                              TextSpan(
                                text: booking.status.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 1,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)),
            )
          : bookings.isEmpty
              ? const Center(
                  child: Text(
                    'No bookings available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOwnerBookingSection(
                        status: 'Pending',
                        bookings: bookings
                            .where((booking) => booking.status == 'pending')
                            .toList(),
                        emptyMessage: 'No pending bookings',
                        color: Colors.orange.shade200,
                      ),
                      const SizedBox(height: 16),
                      _buildOwnerBookingSection(
                        status: 'Accepted',
                        bookings: bookings
                            .where((booking) => booking.status == 'confirmed')
                            .toList(),
                        emptyMessage: 'No accepted bookings',
                        color: Colors.blue.shade200,
                      ),
                      const SizedBox(height: 16),
                      _buildOwnerBookingSection(
                        status: 'Done',
                        bookings: bookings
                            .where((booking) => booking.status == 'done')
                            .toList(),
                        emptyMessage: 'No completed bookings',
                        color: Colors.green.shade200,
                      ),
                      const SizedBox(height: 16),
                      _buildOwnerBookingSection(
                        status: 'Declined',
                        bookings: bookings
                            .where((booking) => booking.status == 'declined')
                            .toList(),
                        emptyMessage: 'No declined bookings',
                        color: Colors.red.shade200,
                      ),
                    ],
                  ),
                ),
    );
  }

// Builds each section based on booking status
  Widget _buildOwnerBookingSection({
    required String status,
    required List<BookingModel> bookings,
    required String emptyMessage,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header for each status
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12.0),

          // If there are no bookings, display a message
          bookings.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    emptyMessage,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    BookingModel booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text(
                          booking.selectedService.join(', ').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${booking.bookingDate}, ${booking.bookingTime}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.php,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  booking.totalPrice.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.store,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  booking.shopName!, // Display the full name
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Status: ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: booking.status.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (booking.status == 'done' &&
                                booking.isFeedbackSubmitted == false)
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FeedbackFormScreen(
                                              bookingId: booking.bookingId,
                                              serviceProviderUid:
                                                  booking.serviceProviderUid,
                                              carOwnerId: booking.carOwnerUid,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 8.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        backgroundColor:
                                            Colors.white, // Button color
                                      ),
                                      child: const Text(
                                        'Give Feedback',
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                    ),
                                  ]),
                            if (booking.status == 'pending')
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Show confirmation dialog
                                      bool? confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Confirm Cancellation'),
                                            content: const Text(
                                              'Are you sure you want to cancel this booking?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false); // Cancel
                                                },
                                                child: const Text(
                                                  'No',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true); // Confirm
                                                },
                                                child: const Text(
                                                  'Yes',
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirm == true) {
                                        await cancelBooking(
                                          booking.bookingId,
                                          booking.serviceProviderUid,
                                          booking.bookingDate,
                                          booking.bookingTime,
                                        );
                                        setState(() {
                                          bookings.removeWhere((b) =>
                                              b.bookingId == booking.bookingId);
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Booking Cancelled Successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      'Cancel Booking',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        onTap: () {
                          // Show the booking details modal when tapped
                          _showBookingDetailsModal([booking]);
                        },
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
