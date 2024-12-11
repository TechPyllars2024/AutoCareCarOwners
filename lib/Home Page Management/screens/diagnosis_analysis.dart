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

Inputs:
Diagnosis Summary:
$summary

Available Services:
$fetchedServiceDetails

**Response Requirements:**
- List up to 10 applicable services based on the diagnosis.
- Clearly state: "No applicable services available" if no services match the diagnosis.
- Use only the provided services—do not create or include non-existent services.
- Consider both the service names and their descriptions carefully.
- Include services from different providers if applicable.

Output Format:
1. [Service Name]
  ''';
  }

  String formattedPromptCauses(String summary,
      {Map<String, dynamic>? carDetails}) {
    return '''
You are an expert car mechanic at an auto repair shop. A customer has brought in their car for a diagnostic check. 
Analyze the following diagnosis summary and provided car details to identify the most probable causes of the issue. Ensure your analysis is accurate, relevant, and tailored to the specific vehicle.

Diagnosis Summary:  
$summary  

${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "- ${e.key}: ${e.value}").join('\n')}" : ""}  

**Response Requirements:**
- Focus on causes that align directly with the car's make, model, year, fuel type, and transmission type.
- Highlight specific patterns or issues commonly associated with the vehicle's details.
- Keep the reasons concise yet informative, and avoid generalizations.
- limit it to 40 words per cause.
- do not put ** in the response
- Remember that we are in the Philippines

**Format Your Response as Follows:**
1. [Explain why this is a likely cause based on the car's details]
2. [Explain why this is a likely cause based on the car's details]
3. Additional Cause: [Include only if relevant based on the summary and car details]
  ''';
  }

  String formattedPromptRecommendations(String summary,
      {Map<String, dynamic>? carDetails}) {
    return '''
You are an expert car mechanic at an auto repair shop. A customer has brought in their car for a diagnostic check. 
Analyze the following diagnosis summary and provided car details to deliver tailored recommendations that directly address the likely issues. Ensure your suggestions are precise, actionable, and relevant to the specific vehicle.

Diagnosis Summary:  
$summary  

${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "- ${e.key}: ${e.value}").join('\n')}" : ""}  

**Response Requirements:**
- Provide recommendations that address the most likely cause(s) of the problem, with a focus on the car’s specific make, model, year, fuel type, and transmission type.
- Include actionable steps (e.g., "Inspect the air filter for blockages and clean/replace as needed").
- If applicable, consider preventive maintenance tips to avoid future issues.
- Avoid generic recommendations; tailor each suggestion to the car's unique details (e.g., "This model is prone to timing belt wear after 80,000 miles; check for wear and tear").
- limit it to 30 words per recommendation.
- do not put ** in the response
- Remember that we are in the Philippines

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

Diagnosis Summary:  
$summary  

${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "- ${e.key}: ${e.value}").join('\n')}" : ""}  

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

2. [Name of the part that requires replacement.]:
   - [Why the part needs replacement and how it relates to the diagnosis. Limit it to 20 words per part.]
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
      appBar: AppBar(
        title: const Text(
          "Diagnosis Analysis",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              responseCauses == null ||
                      responseRecommendations == null ||
                      responseParts == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Generating diagnosis analysis. Please wait...",
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Possible Causes"),
                        const SizedBox(height: 10),
                        _buildContentCard(responseCauses!),
                        const SizedBox(height: 20),
                        _buildSectionHeader("Recommendations"),
                        const SizedBox(height: 10),
                        _buildContentCard(responseRecommendations!),
                        const SizedBox(height: 20),
                        _buildSectionHeader("Replacement of Parts"),
                        const SizedBox(height: 10),
                        _buildContentCard(responseParts!),
                        const SizedBox(height: 20),
                        _buildSectionHeader("Suggested Available Services"),
                        const SizedBox(height: 10),
                        _buildContentCard(responseSuggestedServices),
                        const SizedBox(height: 10),
                        Center(
                          child: responseSuggestedServices !=
                                  "No applicable services available."
                              ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ShopsDirectory(
                                            serviceName:
                                                responseSuggestedServices),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade900,
                                  ),
                                  child: const Text(
                                      'Proceed to Available Services',
                                      style: TextStyle(color: Colors.white)),
                                )
                              : Container(), // Or any other widget you might want to display when there are no applicable services.
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

// Section Header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.orange.shade900,
      ),
    );
  }

// Content Card
  Widget _buildContentCard(String content) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
