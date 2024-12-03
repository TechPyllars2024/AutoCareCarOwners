import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../../Booking Management/services/booking_service.dart';

class Diagnosis extends StatefulWidget {
  const Diagnosis({super.key});

  @override
  State<Diagnosis> createState() => _DiagnosisState();
}

class _DiagnosisState extends State<Diagnosis> {
  List<dynamic> _questions = [];
  Map<String, dynamic> selectedChoices = {};
  List<dynamic> _currentQuestionsStack = [];
  bool _isAnalyzing = false;
  int _currentStep = 0;
  bool _isNextButtonEnabled = false; // Track whether Next button is enabled
  final user = FirebaseAuth.instance.currentUser;
  final Logger logger = Logger();
  Map<String, dynamic>? carDetails;

  // Fetch car details
  Future<void> fetchCarDetails() async {
    try {
      carDetails = await BookingService().fetchDefaultCarDetails(user!.uid);
      logger.i('Car Owner Data: $carDetails');
    } catch (e) {
      logger.e('Error fetching car details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCarDetails(); // Fetch car details once when the widget is initialized
    readJson(); // Automatically load data when the widget is initialized
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/diagnosis.json');
    final data = json.decode(response) as Map<String, dynamic>;
    setState(() {
      _questions = data['diagnosis'] as List<dynamic>;
      _currentQuestionsStack = [_questions];
      _isAnalyzing = false; // Reset analyzing flag when data is loaded
      _isNextButtonEnabled = false; // Ensure Next button is disabled initially
    });
  }

  void _selectChoice(int questionIndex, dynamic choice) {
    setState(() {
      if (_currentQuestions.isEmpty || questionIndex >= _currentQuestions.length) {
        logger.e("Invalid question index or empty questions list.");
        return;
      }

      var currentQuestion = _currentQuestions[questionIndex];
      if (currentQuestion is! Map || !currentQuestion.containsKey('title')) {
        logger.e("Invalid question format or missing 'title'.");
        return;
      }

      String questionId = currentQuestion['title'];
      String selectedChoice = (choice is String) ? choice : choice['choice'];
      selectedChoices[questionId] = selectedChoice;

      var selectedChoiceMap = currentQuestion['choices']
          .firstWhere(
            (c) => (c is String ? c : c['choice']) == selectedChoice,
        orElse: () => null,
      );

      if (selectedChoiceMap != null && selectedChoiceMap['sub_questions'] != null) {
        // If sub-questions exist, add them to the stack
        _currentQuestionsStack.add(selectedChoiceMap['sub_questions']);
        _isAnalyzing = false; // Reset analyzing flag for next question stack
        _isNextButtonEnabled = false; // Disable Next button when sub-questions are present
      } else {
        // If no sub-questions, clear the stack and enable the Next button
        if (_currentQuestionsStack.isNotEmpty) {
          _currentQuestionsStack.clear();
        }
        _isAnalyzing = true;
        _isNextButtonEnabled = true; // Enable Next button if no sub-questions
      }
    });
  }

  List<dynamic> get _currentQuestions => _currentQuestionsStack.isNotEmpty ? _currentQuestionsStack.last : [];

  void _goBack() {
    setState(() {
      if (_currentStep == 0) {
        // If we are on the car details screen, navigate back
        Navigator.of(context).pop(); // Pop the current screen to go back
      } else if (_currentQuestionsStack.isNotEmpty) {
        // If we're not at the very first question, pop the last question set off the stack
        if (_currentQuestionsStack.length > 1) {
          _currentQuestionsStack.removeLast();
        }
        // Go back one step in the question sequence
        if (_currentStep > 1) {
          _currentStep--;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Diagnosis'),
        backgroundColor: Colors.grey.shade100,
      ),
      body: Column(
        children: [
          // Display car details before the Stepper
          if (_currentStep == 0)
            CarDetailsScreen(onNext: () {
              setState(() {
                _currentStep = 1; // Move to Step 1 (first question)
              });
            })
          else
          // Show Stepper with questions after car details are done
            Expanded(
              child: Stepper(
                currentStep: _currentStep - 1, // Adjusting for Stepper's index (first question on step 1)
                onStepTapped: (int index) {
                  setState(() {
                    if (index >= 0 && index < _currentQuestions.length) {
                      _currentStep = index + 1; // Adjust to Stepper's step index
                    }
                  });
                },
                onStepContinue: () {
                  if (_isNextButtonEnabled) {
                    setState(() {
                      if (_currentStep < _currentQuestions.length) {
                        _currentStep++;
                      } else {
                        _isAnalyzing = true; // Set analyzing to true when last step is reached
                      }
                    });
                  }
                },
                onStepCancel: _goBack,
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  return Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isNextButtonEnabled ? details.onStepContinue : null, // Disable if no choice is selected
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade900,
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: details.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade900,
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
                steps: _currentQuestions.isNotEmpty
                    ? [
                  for (var i = 0; i < _currentQuestions.length; i++)
                    Step(
                      title: Text(
                        _currentQuestions[i]['title'] ?? 'No title',
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var choice in _currentQuestions[i]['choices'] ?? [])
                            RadioListTile<String>(
                              title: Text(choice is String
                                  ? choice
                                  : choice['choice']),
                              value: choice is String
                                  ? choice
                                  : choice['choice'],
                              groupValue:
                              selectedChoices[_currentQuestions[i]['title']],
                              onChanged: (value) {
                                _selectChoice(i, choice);
                              },
                              activeColor: Colors.orange.shade900,
                            ),
                        ],
                      ),
                      isActive: _currentStep == i + 1,
                      state: _currentStep == i + 1
                          ? StepState.editing
                          : StepState.indexed,
                    ),
                ]
                    : [],
              ),
            ),
          // Show "Analyzing" message when processing
          if (_isAnalyzing)
            const Center(child: Text('Analyzing the problem')),
        ],
      ),
    );
  }
}

class CarDetailsScreen extends StatelessWidget {
  final VoidCallback onNext;

  const CarDetailsScreen({required this.onNext, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: BookingService().fetchDefaultCarDetails(FirebaseAuth.instance.currentUser!.uid),
      builder: (context, snapshot) {
        // Debugging: print the snapshot's data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          Map<String, dynamic> carDetails = snapshot.data!;

          // Debugging: print the carDetails to check its structure
          print('Car Details: $carDetails');

          // Display car details (you can replace with specific fields if needed)
          return Column(
            children: [
              // Displaying all car details temporarily for debugging
              Text('Car Details: ${carDetails.toString()}'),
              if (carDetails.containsKey('brand'))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text('Brand: ${carDetails['brand']}'),
                ),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade900,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No car details found.'));
        }
      },
    );
  }
}
