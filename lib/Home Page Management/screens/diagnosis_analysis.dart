import 'package:autocare_carowners/Home%20Page%20Management/screens/diagnosis_shops.dart';
import 'package:autocare_carowners/Home%20Page%20Management/services/carDiagnosisData.dart';
import 'package:autocare_carowners/Home%20Page%20Management/widgets/openAI.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'noAvailableServices.dart';

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
  late String processedResponseSuggestedServices;

  @override
  void initState() {
    super.initState();
    loadServiceNames().then((_) {
      Future.wait([
        analyzeDiagnosisCauses(),
        analyzePossibleServices(),
      ]).whenComplete(() {
        preprocessResponseAsync(responseSuggestedServices);
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

  List<String> preprocessServiceNames(String services) {
    // Split by numbers with dots, e.g., "1. Electrical Works"
    List<String> splitServices = services.split(RegExp(r'\d+\.\s*'));
    // Remove empty entries and trim each service name
    return splitServices
        .map((service) => service.trim())
        .where((service) => service.isNotEmpty)
        .toList();
  }

  Future<void> preprocessResponseAsync(String services) async {
    // Simulate an async operation, if needed
    await Future.delayed(const Duration(milliseconds: 10));

    // Split by numbers with dots, e.g., "1. Electrical Works"
    List<String> splitServices = services.split(RegExp(r'\d+\.\s*'));

    // Remove empty entries and trim each service name
    List<String> processedServices = splitServices
        .map((service) => service.trim())
        .where((service) => service.isNotEmpty)
        .toList();

    // Update the state
    setState(() {
      processedResponseSuggestedServices = processedServices.join(', ');
    });
  }

  String capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      return word.isNotEmpty
          ? word[0].toUpperCase() + word.substring(1).toLowerCase()
          : '';
    }).join(' ');
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
- Categories: 'Electrical Works', 'Mechanical Works', 'Air-conditioning Services', 'Paint and Body Works','Car Wash', 'Auto Detailing Services','Roadside Assistance Services', 'Installation of Accessories Services', and 'No applicable services available.'

Response Requirements:
- List up to 10 applicable services based on the diagnosis of possible causes.
- Provide the service names only.
- Use only the PROVIDED services—do not create or include non-existent services.
- Consider both the service names and their descriptions carefully.
- Include services from different providers if applicable.
- Based on the $responseCauses, generalize the issues into one or more applicable Categories and SELECT ONLY from Categories and return it if there is no Available Services.

Format Your Response as Follows:
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
- Prioritize the most likely causes based on the car's details and rank it from 1 onwards. Be sure of this!
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
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange.shade900),
                              ),
                              const SizedBox(height: 30),
                              Text(
                                "Generating diagnosis analysis. Please wait...",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange.shade900),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Possible Causes",
                                color: Colors.black),
                            const SizedBox(height: 10),
                            _buildCauseCards(responseCauses!),
                            const SizedBox(height: 30),
                            _buildSectionHeader("Suggested Available Services",
                                color: Colors.black),
                            const SizedBox(height: 5),
                            _buildContentCard(responseSuggestedServices),
                            const SizedBox(height: 40),
                            Center(
                              child: preprocessServiceNames(
                                          responseSuggestedServices)
                                      .every((service) => ![
                                            'Electrical Works',
                                            'Mechanical Works',
                                            'Air-conditioning Services',
                                            'Paint and Body Works',
                                            'Car Wash',
                                            'Auto Detailing Services',
                                            'Roadside Assistance Services',
                                            'Installation of Accessories Services',
                                            'No applicable services available.'
                                          ].contains(service))
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 40.0),
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
                                  : ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NoAvailableServices(
                                              responseSuggestedServices:
                                                  processedResponseSuggestedServices,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange.shade900,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                          'View Service Providers',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
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
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalizeEachWord(content),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
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
        List<String> displayedCauses =
            showAll ? causes : causes.take(5).toList();

        return Column(
          children: [
            ...displayedCauses.asMap().map((index, cause) {
              // Split the cause into sentences.
              List<String> sentences = cause.split(':');
              String firstSentence =
                  sentences.isNotEmpty ? sentences[0] : cause;
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
                          isExpanded = !isExpanded;
                        });
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: isExpanded
                                ? Colors.white
                                : Colors.grey.shade100,
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
                                  // Icon indicating importance
                                  Icon(
                                    index <= 4
                                        ? Icons.crisis_alert_rounded
                                        : index <= 10
                                            ? Icons.crisis_alert_rounded
                                            : Icons.crisis_alert_rounded,
                                    color: index <= 4
                                        ? Colors.red.shade500
                                        : index <= 9
                                            ? Colors.yellow.shade700
                                            : Colors.green.shade500,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  // GestureDetector for clickable text
                                  GestureDetector(
                                    onTap: () {
                                      // Handle click event to show the full text.
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                              firstSentence.trim(),
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Close',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .orange.shade900),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      firstSentence.length > 30
                                          ? '${firstSentence.substring(0, 30)}...'
                                          : firstSentence.trim(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: index <= 4
                                            ? Colors.black
                                            : index <= 9
                                                ? Colors.black
                                                : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.justify,
                                    ),
                                  ),
                                  const Spacer(),
                                  // Expand/Collapse icon (toggle state)
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
            }).values,
            if (causes.length > 5)
              Row(
                children: [
                  const Spacer(),
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
