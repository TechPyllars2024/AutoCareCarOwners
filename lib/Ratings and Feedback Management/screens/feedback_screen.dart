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
  bool _isLoading = true; // Loading state

  Future<void> _fetchFullName() async {
    final fetchedFullName = await _feedbackService.fetchFullName(widget.carOwnerId);
    setState(() {
      fullName = fetchedFullName!;
      _isLoading = false; // Update loading state
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFullName();
  }

  void _submitFeedback() async {
    if (_rating > 0 && _comment.isNotEmpty) {
      setState(() {
        _isLoading = true; // Set loading state
      });

      String result = await _feedbackService.submitFeedback(
        feedbackerName: fullName,
        bookingId: widget.bookingId,
        serviceProviderUid: widget.serviceProviderUid,
        rating: _rating,
        comment: _comment,
        carOwnerId: widget.carOwnerId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and comment')),
      );
    }
  }

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
            color: index < _rating ? Colors.orange : Colors.grey,
            size: 40, // Adjust size as needed
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.w900))),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text('Rate the service:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildStarRating(), // Include the star rating widget
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                hintText: 'Write your feedback here...',
              ),
              maxLines: 3,
              onChanged: (value) {
                _comment = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.orange, // Button color
                elevation: 5, // Add elevation for shadow effect
              ),
              child: const Text('Submit Feedback', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
