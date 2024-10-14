import 'dart:async';

import 'package:autocare_carowners/ProfileManagement/services/car_owner_bookings_service.dart';
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
  Timer? _timer; // Timer for auto-refresh

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      _loadBookings();
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

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
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
                              Icons
                                  .php, // Use an appropriate icon (monetization_on is a money icon)
                              color: Colors.blue, // Set the color of the icon
                              size: 20, // Set the size of the icon
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking.totalPrice
                                  .toString(), // Convert double to String
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
                            const SizedBox(
                                width: 5), // Space between the icon and text
                            Text(
                              booking.shopName!, // Display the full name
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
                            const SizedBox(
                                width: 5), // Space between the icon and text
                            Text(
                              booking.shopAddress!, // Display the full name
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
                              Icons
                                  .local_gas_station, // Use an appropriate icon for fuel type
                              color: Colors.blue, // Set the color of the icon
                              size: 20, // Set the size of the icon
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking.fuelType,
                              style: const TextStyle(
                                  fontSize: 14), // Set a suitable font size
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons
                                  .settings, // Use an appropriate icon for transmission
                              color: Colors.blue, // Set the color of the icon
                              size: 20, // Set the size of the icon
                            ),
                            const SizedBox(width: 5),
                            Text(
                              booking
                                  .transmission, // Display the transmission type
                              style: const TextStyle(
                                  fontSize: 14), // Set a suitable font size
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Display status if currently processing or loading
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text:
                                    'Status: ', // Keep 'Status:' in default color
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Default color
                                ),
                              ),
                              TextSpan(
                                text:
                                    booking.status.toUpperCase(), // Capitalized status
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange, // Set color to orange
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
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Set a contrasting color for visibility
          ),
        ),
        elevation: 1, // Add a slight elevation for a material design effect
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Display loader when fetching data
          : bookings.isEmpty
              ? const Center(
                  child: Text(
                    'No bookings available',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey), // Style for the empty state
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(
                      16.0), // Add padding for overall layout
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align text to start
                    children: [
                      _buildOwnerBookingSection(
                        status: 'Pending',
                        bookings: bookings
                            .where((booking) => booking.status == 'pending')
                            .toList(),
                        emptyMessage: 'No pending bookings',
                        color: Colors.orange.shade200,
                      ),
                      const SizedBox(height: 16), // Space between sections
                      _buildOwnerBookingSection(
                        status: 'Accepted',
                        bookings: bookings
                            .where((booking) => booking.status == 'confirmed')
                            .toList(),
                        emptyMessage: 'No accepted bookings',
                        color: Colors.blue.shade200,
                      ),
                      const SizedBox(height: 16), // Space between sections
                      _buildOwnerBookingSection(
                        status: 'Done',
                        bookings: bookings
                            .where((booking) => booking.status == 'done')
                            .toList(),
                        emptyMessage: 'No completed bookings',
                        color: Colors.green.shade200,
                      ),
                      const SizedBox(height: 16), // Space between sections
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

          const SizedBox(height: 12.0), // Spacing between header and content

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
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling since ListView is nested
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
                                  Icons
                                      .calendar_today, // Calendar icon for booking date
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(
                                    width:
                                        5), // Space between the icon and text
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
                                  Icons.php, // Money icon for total price
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(
                                    width:
                                        5), // Space between the icon and text
                                Text(
                                  booking.totalPrice.toStringAsFixed(
                                      2), // Show price with currency
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
                                const SizedBox(
                                    width:
                                        5), // Space between the icon and text
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
                            const SizedBox(
                                height: 8.0), // Spacing before the button
                            // Align the button to the right side
                            if (booking.status == 'done' && booking.isFeedbackSubmitted == false) // Check if status is 'done' and feedback not submitted
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        // Navigate to Feedback Form Screen and await feedback submission
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
