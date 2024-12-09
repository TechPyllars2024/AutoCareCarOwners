import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../Booking Management/services/booking_service.dart';
import '../widgets/CarDetailsWidget.dart';
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
  bool _isNextButtonEnabled = false;
  final user = FirebaseAuth.instance.currentUser;
  final Logger logger = Logger();
  Map<String, dynamic>? carDetails;

  Future<Map<String, dynamic>> fetchCarDetails() async {
    try {
      Map<String, dynamic> fetchedCarDetails =
      await BookingService().fetchDefaultCarDetails(user!.uid);

      logger.i('Car Owner Data: $fetchedCarDetails');
      return fetchedCarDetails;
    } catch (e) {
      logger.e('Error fetching car details: $e');
      return {};
    }
  }

  void navigateToAddCarDetails() {
    // Navigate to the "Add Car Details" screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Placeholder()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCarDetails().then((details) {
      setState(() {
        carDetails = details;
      });
    });
    readJson();
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/diagnosis.json');
    final data = json.decode(response) as Map<String, dynamic>;
    setState(() {
      _questions = data['diagnosis'] as List<dynamic>;
      _currentQuestionsStack = [_questions];
      _isAnalyzing = false;
      _isNextButtonEnabled = false;
    });
  }

  void _selectChoice(int questionIndex, dynamic choice) {
    setState(() {
      if (_currentQuestionsStack.isEmpty || questionIndex >= _currentQuestionsStack.length) {
        logger.e("Invalid question index or empty questions stack.");
        return;
      }

      var currentQuestion = _currentQuestionsStack.last[questionIndex];
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
        _currentQuestionsStack.add(selectedChoiceMap['sub_questions']);
        _isAnalyzing = false;
        _isNextButtonEnabled = false; // Disable Next button while sub-questions exist
      } else {
        _isAnalyzing = true;
        _isNextButtonEnabled = true; // Enable Next button if no sub-questions
      }
    });
  }

  List<dynamic> get _currentQuestions => _currentQuestionsStack.isNotEmpty ? _currentQuestionsStack.last : [];

  void _goBack() {
    setState(() {
      if (_currentStep == 0) {
        Navigator.of(context).pop();
      } else if (_currentQuestionsStack.isNotEmpty) {
        if (_currentQuestionsStack.length > 1) {
          _currentQuestionsStack.removeLast();
        }
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
          if (_currentStep == 0)
            Column(
              children: [
                CarDetailsWidget(
                  carDetailsData: fetchCarDetails(),
                  navigateToCarDetails: navigateToAddCarDetails,
                ),
                // Only show the 'Next' button when car details are fetched
                if (carDetails != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1; // Move to stepper
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade900,
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            )
          else
            Expanded(
              child: Stepper(
                currentStep: _currentStep - 1,
                onStepTapped: (int index) {
                  setState(() {
                    if (index >= 0 && index < _currentQuestions.length) {
                      _currentStep = index + 1;
                    }
                  });
                },
                onStepContinue: () {
                  if (_isNextButtonEnabled) {
                    setState(() {
                      if (_currentStep < _currentQuestions.length) {
                        _currentStep++;
                      } else {
                        _isAnalyzing = true;
                      }
                    });
                  }
                },
                onStepCancel: _goBack,
                controlsBuilder: (BuildContext context, ControlsDetails details) {
                  return Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isNextButtonEnabled ? details.onStepContinue : null,
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
          if (_isAnalyzing)
            const Center(child: Text('Analyzing the problem')),
        ],
      ),
    );
  }
}
