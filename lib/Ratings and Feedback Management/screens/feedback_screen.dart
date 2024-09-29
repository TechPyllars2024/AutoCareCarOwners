import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackFormScreen extends StatefulWidget {
  final String bookingId;
  final String serviceProviderUid;
  final String carOwnerId;

  const FeedbackFormScreen({
    super.key,
    required this.bookingId,
    required this.serviceProviderUid,
    required this.carOwnerId,
  });

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  int _rating = 0;
  String _comment = '';
  late final String fullName;

  Future<void> _fetchFullName() async {
    final fetchedFullName = await FeedbackService().fetchFullName(widget.carOwnerId);
    setState(() {
      fullName = fetchedFullName!;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFullName();
  }


  void _submitFeedback() async {
    if (_rating > 0) {
      String result = await _feedbackService.submitFeedback(
        feedbackerName: fullName,
        bookingId: widget.bookingId,
        serviceProviderUid: widget.serviceProviderUid,
        rating: _rating,
        comment: _comment,
        carOwnerId: widget.carOwnerId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)), // Show feedback result
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating.')),
      );
    }
  }

  // Method to build the star rating widget
  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1; // Set rating based on tapped star
            });
          },
          child: Icon(
            Icons.star,
            color: index < _rating ? Colors.amber : Colors.grey,
            size: 40, // Adjust size as needed
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Rate the service:'),
            const SizedBox(height: 10),
            buildStarRating(), // Include the star rating widget
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: 'Comment'),
              maxLines: 3,
              onChanged: (value) {
                _comment = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
