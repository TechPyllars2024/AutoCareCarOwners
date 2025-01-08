import 'package:autocare_carowners/Home%20Page%20Management/screens/diagnosis_shops.dart';
import 'package:autocare_carowners/Home%20Page%20Management/services/carDiagnosisData.dart';
import 'package:autocare_carowners/Home%20Page%20Management/widgets/openAI.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class OpenAIEntryScreen extends StatefulWidget {
  final String summary;
  final Map<String, dynamic>? carDetails;

  const OpenAIEntryScreen({super.key, required this.summary, this.carDetails});

  @override
  State<OpenAIEntryScreen> createState() => _OpenAIEntryScreenState();
}

class _OpenAIEntryScreenState extends State<OpenAIEntryScreen> {
  String? responseCauses;

  late List<Map<String, dynamic>>? serviceDetails;
  late List<String>? serviceNames = [];
  late List<String>? serviceDescriptions = [];
  late List<String>? serviceIDs = [];
  bool isLoading = true;
  late String responseSuggestedServices;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    loadServiceNames().then((_) {
      Future.wait([
        analyzeDiagnosisCauses(),
        analyzePossibleServices(),
      ]).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    }).catchError((e) {
      logger.e('Error loading service names: $e');
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> loadServiceNames() async {
    setState(() {
      isLoading = true;
    });
    try {
      logger.i('Attempting to fetch service details...');
      List<Map<String, dynamic>> fetchedServiceDetails =
          await CarDiagnosis().fetchVerifiedServiceDetails();
      logger.i(fetchedServiceDetails);

      // Extract only the names for simplicity
      List fetchedServiceNames =
          fetchedServiceDetails.map((service) => service['name']).toList();

      setState(() {
        serviceDetails = fetchedServiceDetails;
        serviceNames = fetchedServiceNames.cast<String>();
        serviceDescriptions = fetchedServiceDetails
            .map((service) => service['description'])
            .cast<String>()
            .toList();
        serviceIDs = fetchedServiceDetails
            .map((service) => service['serviceID'])
            .cast<String>()
            .toList();
        isLoading = false;
      });

      logger.i(
          'Successfully fetched service details: ${fetchedServiceDetails.length} details retrieved.');
    } catch (e) {
      logger.e('Error fetching service details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String formattedPromptSuggestedServices(
      String summary, List<Map<String, dynamic>> fetchedServiceDetails) {
    return '''
You are an expert auto mechanic at a professional repair shop. A customer has brought their car for a diagnostic evaluation.
Based on the Diagnosis Summary and the List of Available Services (considering service names and descriptions), provide the most relevant services to address the identified issues. Ensure your recommendations are precise, tailored to the customer’s needs, and limited to the services listed.

Diagnostic Input:
- Diagnosis Summary: $summary
- Possible Causes: $responseCauses
- Available Services: $fetchedServiceDetails

**Response Requirements:**
- List up to 10 applicable services based on the diagnosis of possible causes.
- Clearly state: "No applicable services available." if no services match the diagnosis.
- Use only the provided services—do not create or include non-existent services.
- Consider both the service names and their descriptions carefully.
- Include services from different providers if applicable.

**Format Your Response as Follows:**
1. [Service Name ONLY]
  ''';
  }

  String formattedPromptCauses(String summary,
      {Map<String, dynamic>? carDetails}) {
    return '''
You are an expert car mechanic at an auto repair shop. A customer has brought in their car for a diagnostic check. 
Analyze the following diagnosis summary and provided car details to identify the most probable causes of the issue. Ensure your analysis is accurate, relevant, and tailored to the specific vehicle.

Diagnostic Input:  
- Summary: $summary  
- Car Details: ${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "${e.key}: ${e.value}").join('\n')}" : ""}  

Response Requirements:
- Focus on causes that align directly with the car's make, model, year, fuel type, and transmission type.
- Highlight specific patterns or issues commonly associated with the vehicle's details.
- Keep the reasons concise yet informative, and avoid generalizations.
- Limit it to 40 words per cause.
- Understand other language nuances and provide a culturally appropriate response.
- Do not use special characters or formatting like **, --, or numbering in your response.
- Remember that the car is used in the Philippines.
- Prioritize the most likely causes based on the car's details and rank it from 1 onwards.
- List all the possible causes up to 15 in plain text.
- Be mindful of the fuelType and transmissionType when providing the causes.
- If there is no possible cause and the $summary is random or you cannot understand, state: "No possible causes found."

Format Your Response as Follows:
1. Explain why this is a likely cause based on the car's details and give a recommendation on how to fix it.
2. Provide your answer in a simple list without any numbering or bullets.
3. STRICTLY Do not use special characters like **, --, or any formatting other than plain text.
  ''';
  }

  Future<void> analyzePossibleServices() async {
    String prompt =
        formattedPromptSuggestedServices(widget.summary, serviceDetails!);
    try {
      String? aiResponse = await ChatService().request(prompt);
      setState(() {
        responseSuggestedServices =
            aiResponse ?? "No response received. Please try again.";
      });
    } catch (error) {
      setState(() {
        responseSuggestedServices =
            "Failed to fetch AI analysis. Please check your connection and try again.";
      });
    }
  }

  Future<void> analyzeDiagnosisCauses() async {
    String prompt = formattedPromptCauses(
      widget.summary,
      carDetails: widget.carDetails,
    );
    try {
      String? aiResponse = await ChatService().request(prompt);
      setState(() {
        responseCauses =
            aiResponse ?? "No response received. Please try again.";
      });
    } catch (error) {
      setState(() {
        responseCauses =
            "Failed to fetch AI analysis. Please check your connection and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text(
            "Diagnosis Analysis",
            style: TextStyle(
                fontWeight: FontWeight.w900, color: Colors.white, fontSize: 20),
          ),
          backgroundColor: Colors.orange.shade900,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  responseCauses == null
                      ?  Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.orange.shade900),
                              ),
                              SizedBox(height: 30),
                              Text(
                                "Generating diagnosis analysis. Please wait...",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.orange.shade900),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Possible Causes",
                                color: Colors.black),
                            const SizedBox(height: 5),
                            _buildCauseCards(responseCauses!),
                            const SizedBox(height: 30),
                            _buildSectionHeader("Suggested Available Services",
                                color: Colors.black),
                            const SizedBox(height: 5),
                            _buildContentCard(responseSuggestedServices),
                            const SizedBox(height: 10),
                            Center(
                              child: responseSuggestedServices !=
                                      "No applicable services available."
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height: 50,

                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ShopsDirectory(
                                                        serviceName:
                                                            responseSuggestedServices),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orange.shade900,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                              'Proceed to Available Services',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ));
  }

// Section Header
  Widget _buildSectionHeader(String title, {Color color = Colors.black}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,

      ),
    );
  }

// Content Card
  Widget _buildContentCard(String content) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding:  EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          content,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }


  Widget _buildCauseCards(String content) {
    List<String> causes = content.replaceAll('**', '').split('\n');
    bool showAll = false;

    return StatefulBuilder(
      builder: (context, setState) {
        // Determine the list of causes to display based on the state of `showAll`.
        List<String> displayedCauses = showAll ? causes : causes.take(5).toList();

        return Column(
          children: [
            ...displayedCauses.asMap().map((index, cause) {
              // Split the cause into sentences.
              List<String> sentences = cause.split(':');
              String firstSentence = sentences.isNotEmpty ? sentences[0] : cause;
              String remainingContent =
              sentences.length > 1 ? sentences.sublist(1).join('.') : '';
              bool isExpanded = false;

              return MapEntry(
                index,
                StatefulBuilder(
                  builder: (context, cardSetState) {
                    return GestureDetector(
                      onTap: () {
                        cardSetState(() {
                          isExpanded = !isExpanded; // Toggle the expanded state.
                        });
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: isExpanded ? Colors.white : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Handle click event to show the full text.
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              firstSentence.trim(),
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Close',
                                                  style: TextStyle(color: Colors.orange),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      firstSentence.length > 35
                                          ? '${firstSentence.substring(0, 35)}...'
                                          : firstSentence.trim(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: index < 5
                                            ? Colors.orange.shade900 // Change to the desired color for the first five cards
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.orange.shade900,
                                  ),
                                ],
                              ),
                              if (isExpanded) ...[
                                const SizedBox(height: 10),
                                Text(
                                  remainingContent.trim(),
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).values.toList(),
            if (causes.length > 5) // Show "See More" or "Show Less" if needed.
              Row(
                children: [
                  const Spacer(), // Push the text to the right.
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAll = !showAll; // Toggle the `showAll` state.
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        showAll ? 'Show Less' : 'See More',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }



}
