import 'dart:convert';
import 'package:autocare_carowners/Home%20Page%20Management/screens/diagnosis_analysis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../../Booking Management/services/booking_service.dart';
import '../../ProfileManagement/screens/car_owner_car_details.dart';
import '../widgets/CarDetailsWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class Diagnosis extends StatefulWidget {
  const Diagnosis({super.key, this.child});

  final Widget? child;

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

  void _showDiagnosisSummary(BuildContext context) {
    final summary = selectedChoices.entries.map((entry) {
      return "${entry.key}: ${entry.value}";
    }).join('\n');

    // Ensure carDetails is not null before proceeding
    if (carDetails == null) {
      logger.w('Car details are not available.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Car details are not loaded yet. Please try again later.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: Colors.white,
          // Change the dialog background color here
        ),
        child: AlertDialog(


          title: Text('Summary',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.orange.shade900)),
          content: Container(

            constraints: const BoxConstraints(maxHeight: 400.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: selectedChoices.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "${entry.key}:",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 30,),
                        Expanded(
                          child: Text(entry.value, style: const TextStyle(fontSize: 11),
                        ),
                        )],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),),
              ),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OpenAIEntryScreen(
                        summary: summary, carDetails: carDetails),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),),
              ),
              child: const Text('Analyse', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

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

  void navigateToCarDetails() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CarDetails()),
    );
    setState(() {
      fetchCarDetails().then((details) {
        setState(() {
          carDetails = details;
        });
      });
    });
  }

  Future<void> readJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/diagnosis.json');
      final data = json.decode(response) as Map<String, dynamic>;
      setState(() {
        _questions = data['diagnosis'] as List<dynamic>;
        _currentQuestionsStack = [_questions];
        _isAnalyzing = false;
        _isNextButtonEnabled = false;
      });
    } catch (e) {
      logger.e('Error reading JSON file: $e');
    }
  }

  void _selectChoice(int questionIndex, dynamic choice) {
    setState(() {
      if (questionIndex < 0 || questionIndex >= _currentQuestions.length) {
        logger.e("Invalid question index: $questionIndex");
        return;
      }

      var currentQuestion = _currentQuestions[questionIndex];
      if (currentQuestion is! Map || currentQuestion['title'] is! String) {
        logger.e("Invalid question structure at index $questionIndex");
        return;
      }

      String questionId = currentQuestion['title'];
      String selectedChoice = choice is String
          ? choice
          : (choice is Map && choice['choice'] is String
              ? choice['choice']
              : '');

      if (selectedChoice.isEmpty) {
        logger.e("Empty choice selected for question: $questionId");
        return;
      }

      selectedChoices[questionId] = selectedChoice;

      var selectedChoiceMap = currentQuestion['choices'].firstWhere(
        (c) => (c is String ? c : c['choice']) == selectedChoice,
        orElse: () => null, // Return null instead of ''
      );

      if (selectedChoiceMap != null &&
          selectedChoiceMap is Map &&
          selectedChoiceMap['sub_questions'] != null) {
        _currentQuestionsStack.add(selectedChoiceMap['sub_questions']);
        _isAnalyzing = false;
        _isNextButtonEnabled = false;
      } else {
        _isAnalyzing = true;
        _isNextButtonEnabled = true;
      }
    });
  }

  List<dynamic> get _currentQuestions =>
      _currentQuestionsStack.isNotEmpty ? _currentQuestionsStack.last : [];

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

  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      logger.e('Could not launch URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Diagnosis',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 20)),
        backgroundColor: Colors.grey.shade100,
      ),
      body: Stack(

        children: [
          if (_currentStep == 0)
            Column(

              children: [
                CarDetailsWidget(
                  carDetailsData: fetchCarDetails(),
                  navigateToCarDetails: navigateToCarDetails,
                ),

                Spacer(),



                if (carDetails != null)
                  Align(

                    alignment: Alignment.center,

                    child: Stack(
                      children: [



                        Center(

                          child: Padding(

                            padding: const EdgeInsets.all(20.0),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentStep = 1;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade900,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15), // Curved edges
                                ),
                              ),
                              child: const Text('Proceed',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
          else
            Stepper(
              currentStep: _currentStep - 1,
              onStepTapped: (int index) {
                setState(() {
                  if (index >= 0 && index < _currentQuestions.length) {
                    _currentStep = index + 1;
                  }
                });
              },
              onStepContinue: () {
                setState(() {
                  if (_currentStep < _currentQuestions.length) {
                    // Proceed to the next step if available
                    if (_isNextButtonEnabled) {
                      _currentStep++;
                    }
                  } else {
                    // All steps are completed, show the diagnosis summary
                    _showDiagnosisSummary(context);
                  }
                });
              },
              onStepCancel: _goBack,
              controlsBuilder:
                  (BuildContext context, ControlsDetails details) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        ElevatedButton(
                          onPressed: details.onStepCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 40.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Curved edges
                            ),
                          ),
                          child: const Text('Back',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isNextButtonEnabled
                              ? details.onStepContinue
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade900,
                            minimumSize: Size(MediaQuery.of(context).size.width * 0.3, 40.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Curved edges
                            ),
                          ),
                          child: const Text('Next',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                );
              },
              steps: _currentQuestions.isNotEmpty
                  ? [
                      for (var i = 0; i < _currentQuestions.length; i++)
                        Step(
                          title: Text(
                              _currentQuestions[i]['title'] ?? 'No title'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var choice
                                  in _currentQuestions[i]['choices'] ?? [])
                                if (choice is Map &&
                                    choice.containsKey('choice'))
                                  Column(
                                    children: [
                                      if (choice.containsKey('image_url'))
                                        SizedBox(
                                          width: 60.0,
                                          height: 60.0,
                                          child: Image.network(
                                            choice['image_url'],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      RadioListTile<String>(
                                        title: Text(choice['choice'] ??
                                            'No name available'),
                                        value: choice['choice'] ?? '',
                                        groupValue: selectedChoices[
                                            _currentQuestions[i]['title']],
                                        onChanged: (value) {
                                          _selectChoice(i, choice);
                                        },
                                        activeColor: Colors.orange.shade900,
                                      ),
                                    ],
                                  )
                                else
                                  RadioListTile<String>(
                                    title: Text(choice is String
                                        ? choice
                                        : choice['choice'] ??
                                            'No choice available'),
                                    value: choice is String
                                        ? choice
                                        : choice['choice'] ?? '',
                                    groupValue: selectedChoices[
                                        _currentQuestions[i]['title']],
                                    onChanged: (value) {
                                      _selectChoice(i, choice);
                                    },
                                    activeColor: Colors.orange.shade900,
                                  ),
                            ],
                          ),
                        )
                    ]
                  : [],
            ),
        ],
      ),
    );
  }
}
