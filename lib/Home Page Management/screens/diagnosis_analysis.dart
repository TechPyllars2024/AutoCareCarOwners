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
  String? responseRecommendations;
  String? responseParts;
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
        analyzeDiagnosisParts(),
        analyzeDiagnosisRecommendations(),
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
- Available Services: $fetchedServiceDetails

**Response Requirements:**
- List up to 10 applicable services based on the diagnosis.
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
- Car Details: ${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "- ${e.key}: ${e.value}").join('\n')}" : ""}  

**Response Requirements:**
- Focus on causes that align directly with the car's make, model, year, fuel type, and transmission type.
- Highlight specific patterns or issues commonly associated with the vehicle's details.
- Keep the reasons concise yet informative, and avoid generalizations.
- limit it to 40 words per cause.
- do not put ** in the response
- Remember that we are in the Philippines
- list all the possible causes up to 15

**Format Your Response as Follows:**
1. [Explain why this is a likely cause based on the car's details]
2. [Explain why this is a likely cause based on the car's details]
3. [Provide your answer in a simple list, but without any numbers or bullets.]
4. [Do not use any numbering or bullets in your response. Write everything in plain text or as a paragraph.]
5. [Don't use special characters like ** or -- in your response.]





  ''';
  }

  String formattedPromptRecommendations(String summary,
      {Map<String, dynamic>? carDetails}) {
    return '''
You are an expert car mechanic at an auto repair shop. A customer has brought in their car for a diagnostic check. 
Analyze the following diagnosis summary and provided car details to deliver tailored recommendations that directly address the likely issues. Ensure your suggestions are precise, actionable, and relevant to the specific vehicle.

Diagnostic Input:  
- Summary: $summary  
- Car Details: ${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "- ${e.key}: ${e.value}").join('\n')}" : ""}  

**Response Requirements:**
- Provide recommendations that address the most likely cause(s) of the problem, with a focus on the car’s specific make, model, year, fuel type, and transmission type.
- Include actionable steps (e.g., "Inspect the air filter for blockages and clean/replace as needed").
- If applicable, consider preventive maintenance tips to avoid future issues.
- Avoid generic recommendations; tailor each suggestion to the car's unique details (e.g., "This model is prone to timing belt wear after 80,000 miles; check for wear and tear").
- limit it to 30 words per recommendation.
- do not put ** in the response
- Remember that we are in the Philippines
- your responses should have a 5 word title and ends with a colon (:)

**Format Your Response as Follows:**
1. [Actionable suggestion based on diagnosis summary and car details.]
2. [Actionable suggestion or preventive advice.]
  ''';
  }

  String formattedPromptParts(String summary,
      {Map<String, dynamic>? carDetails}) {
    return '''
You are an expert car mechanic at an auto repair shop. A customer has brought in their car for a diagnostic check. 
Analyze the following diagnosis summary and consider the provided car details. Identify any parts that need to be replaced, ensuring that your recommendations are precise, necessary, and relevant to the specific vehicle.

Diagnostic Input:  
- Summary: $summary  
- Car Details: ${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "- ${e.key}: ${e.value}").join('\n')}" : ""}

**Response Requirements:**
- Only recommend parts that are essential to resolving the diagnosed issue.
- Explain why each part needs replacement based on the diagnosis summary and car details (e.g., "This model often experiences fuel pump wear after 100,000 miles; replacement is necessary to restore proper fuel pressure").
- Consider the car's make, model, year, mileage, and any unique features (e.g., hybrid systems, turbochargers) when identifying parts.
- Avoid suggesting unnecessary replacements.
- do not put ** in the response
- Remember that we are in the Philippines

**Provide your response in the following format:**

1. [Name of the part that requires replacement.]:
   - [Why the part needs replacement and how it relates to the diagnosis.Limit it to 20 words per part.]
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

  Future<void> analyzeDiagnosisRecommendations() async {
    String prompt = formattedPromptRecommendations(
      widget.summary,
      carDetails: widget.carDetails,
    );
    try {
      String? aiResponse = await ChatService().request(prompt);
      setState(() {
        responseRecommendations =
            aiResponse ?? "No response received. Please try again.";
      });
    } catch (error) {
      setState(() {
        responseRecommendations =
            "Failed to fetch AI analysis. Please check your connection and try again.";
      });
    }
  }

  Future<void> analyzeDiagnosisParts() async {
    String prompt = formattedPromptParts(
      widget.summary,
      carDetails: widget.carDetails,
    );
    try {
      String? aiResponse = await ChatService().request(prompt);
      setState(() {
        responseParts = aiResponse ?? "No response received. Please try again.";
      });
    } catch (error) {
      setState(() {
        responseParts =
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
        body:
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade900, Colors.orange.shade600],
              // Customize colors as needed
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child:
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  responseCauses == null ||
                          responseRecommendations == null ||
                          responseParts == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Generating diagnosis analysis. Please wait...",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader("Possible Causes", color: Colors.white),
                            const SizedBox(height: 5),
                            _buildCauseCards(responseCauses!),
                            // const SizedBox(height: 30),
                            // _buildSectionHeader("Recommendations"),
                            // const SizedBox(height: 5),
                            // _buildContentCard(responseRecommendations!),
                            // const SizedBox(height: 30),
                            // _buildSectionHeader("Replacement of Parts"),
                            // const SizedBox(height: 5),
                            // _buildContentCard(responseParts!),
                            const SizedBox(height: 30),
                            _buildSectionHeader("Suggested Available Services", color: Colors.white),
                            const SizedBox(height: 5),
                            _buildContentCard(responseSuggestedServices),
                            const SizedBox(height: 10),
                            Center(
                              child: responseSuggestedServices !=
                                      "No applicable services available."
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Container(
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
                                  : Container(), // Or any other widget you might want to display when there are no applicable services.
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
  Widget _buildSectionHeader(String title, {Color color = Colors.white}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: [
          Shadow(
            offset: Offset(1.0, 1.0), // Position of the shadow
            blurRadius: 4.0, // Blur effect for the shadow
            color: Colors.grey.shade900, // Shadow color
          ),
        ],
      ),
    );
  }


// Content Card
  Widget _buildContentCard(String content) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
    List<String> causes = content.split('\n');
    return Column(
      children: causes.map((cause) {
        // Split the cause into sentences
        List<String> sentences = cause.split(':');

        // Check if the cause has more than one sentence
        String firstSentence = sentences.isNotEmpty ? sentences[0] : cause;
        String remainingContent =
            sentences.length > 1 ? sentences.sublist(1).join('.') : '';

        bool isExpanded = false; // Track the expanded state for each cause

        return StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // Toggle the expanded state
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
                          Text(
                            firstSentence.trim(),
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.justify,
                          ),
                          Spacer(),
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
        );
      }).toList(),
    );
  }
}
