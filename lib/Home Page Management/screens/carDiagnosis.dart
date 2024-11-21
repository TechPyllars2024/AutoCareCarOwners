import 'package:autocare_carowners/Home%20Page%20Management/widgets/CarDetailsWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../Booking Management/services/booking_service.dart';

class Cardiagnosis extends StatefulWidget {
  const Cardiagnosis({super.key});

  @override
  State<Cardiagnosis> createState() => _CardiagnosisState();
}

class _CardiagnosisState extends State<Cardiagnosis> {
  int _currentStep = 0;
  final user = FirebaseAuth.instance.currentUser;
  final Logger logger = Logger();

  // Simulated car details data
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

  // Track the selected item index for each step
  Map<int, int?> _selectedOptions = {};

  // Helper Methods for Diagnosing Car Issues
  List<Map<String, dynamic>> getCarIsNotStartingChecklist() {
    switch (_selectedOptions[1]) {
      case 0: // "Key can't be turned"
        return [
          {'title': 'Regular metal key', 'value': 0},
          {'title': 'Push button', 'value': 1},
        ];
      case 1: // "I am able to turn the key"
        return [
          {'title': 'I hear noise from engine', 'value': 0},
          {'title': 'I don’t hear noise from engine', 'value': 1},
        ];
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> getChecklistItems() {
    switch (_selectedOptions[0]) {
      case 0: // "Car is not starting"
        return [
          {'title': 'Key can\'t be turned', 'value': 0},
          {'title': 'I am able to turn the key', 'value': 1},
        ];
      case 1: // "Windows are not moving"
        return []; // Add relevant checklist items
      case 2: // "Air conditioning is not working"
        return [
          {'title': 'Air conditioner is blowing hot air', 'value': 0},
          {'title': 'Air conditioner is blowing cold air', 'value': 1},
        ];
      default:
        return [];
    }
  }

  // Handle the change in selected checkbox for a step
  void handleSelection(int step, int index) {
    setState(() {
      _selectedOptions[step] = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Car Diagnosis'),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.orange.shade900, // Sets the current step circle color
            ),
          ),
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() {
                  _currentStep += 1;
                });
              }
            },
            onStepTapped: (int index) {
              setState(() {
                _currentStep = index;
              });
            },
            steps: <Step>[
              Step(
                title: const Text('Step 1: Car Details'),
                content: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      const Text('Details for initial vehicle check.'),
                      const SizedBox(height: 16),
                      CarDetailsWidget(
                        carDetailsData: fetchCarDetails(),
                        navigateToCarDetails: navigateToAddCarDetails,
                      ),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('Step 2: What is your concern?'),
                content: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select what your issue is.'),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          RadioListTile<int>(
                            title: const Text('Car is not starting'),
                            value: 0,
                            groupValue: _selectedOptions[0],
                            onChanged: (int? value) {
                              handleSelection(0, value!);
                            },
                          ),
                          RadioListTile<int>(
                            title: const Text('Windows are not moving'),
                            value: 1,
                            groupValue: _selectedOptions[0],
                            onChanged: (int? value) {
                              handleSelection(0, value!);
                            },
                          ),
                          RadioListTile<int>(
                            title: const Text('Air conditioning is not working'),
                            value: 2,
                            groupValue: _selectedOptions[0],
                            onChanged: (int? value) {
                              handleSelection(0, value!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Display next checklist based on the first selection
                      if (_selectedOptions[0] == 0)
                        Column(
                          children: getChecklistItems().map((item) {
                            return RadioListTile<int>(
                              title: Text(item['title']),
                              value: item['value'],
                              groupValue: _selectedOptions[1],
                              onChanged: (int? value) {
                                handleSelection(1, value!);
                              },
                            );
                          }).toList(),
                        ),
                      // Display next checklist based on the second selection
                      if (_selectedOptions[0] == 0 &&
                          _selectedOptions[1] != null)
                        Column(
                          children: getCarIsNotStartingChecklist().map((item) {
                            return RadioListTile<int>(
                              title: Text(item['title']),
                              value: item['value'],
                              groupValue: _selectedOptions[2],
                              onChanged: (int? value) {
                                handleSelection(2, value!);
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('Step 3: Diagnosis'),
                content: Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      const Text('Analyzing the problem.'),
                      const SizedBox(height: 16),
                    ],
                  ),//
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}