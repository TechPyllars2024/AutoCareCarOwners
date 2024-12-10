import 'package:autocare_carowners/Home%20Page%20Management/widgets/openAI.dart';
import 'package:flutter/material.dart';

class OpenAIEntryScreen extends StatefulWidget {
  final String summary;
  final Map<String, dynamic>? carDetails;

  const OpenAIEntryScreen({super.key, required this.summary, this.carDetails});

  @override
  State<OpenAIEntryScreen> createState() => _OpenAIEntryScreenState();
}

class _OpenAIEntryScreenState extends State<OpenAIEntryScreen> {
  String? response;

  @override
  void initState() {
    super.initState();
    analyzeDiagnosis();
  }

  String formattedPrompt(String summary, {Map<String, dynamic>? carDetails}) {
    return '''
You are an expert car mechanic at an auto repair shop. A customer has brought in their car for a diagnostic check. 
Analyze the following diagnosis summary and consider the provided car details. Tailor the possible causes and recommendations accordingly to ensure accuracy and relevance to the vehicle.

Diagnosis Summary:  
$summary  

${carDetails != null ? "Car Details:\n${carDetails.entries.map((e) => "- ${e.key}: ${e.value}").join('\n')}" : ""}  

**Response Requirements:**
- Provide a concise analysis based on the diagnosis summary and car details. (Limit to 50 words)
- Focus on the most likely causes and prioritize mechanical causes if applicable.
- Provide concise recommendations and only suggest parts if they are necessary and relevant to the problem.
- In the Possible Cause(s) section, try to give reasons why it happens based on the car details such as make, model, fuel type, transmission type, and year if necessary. For example, consider how these factors might influence common issues like fuel delivery problems, electrical issues, or mechanical failures.

Provide your analysis in the following format:

**Possible Cause(s):**
- Cause 1 Reason based on the car details (e.g., "Fuel delivery issues might be more likely due to the car's age and fuel type").
- Cause 2 Reason based on the car details (e.g., "Electrical issues could be more frequent in models with a history of problematic wiring").

**Recommendation(s):**
- Recommendation 1 Directly addresses the most likely cause and considers the car's specifics.
- Recommendation 2 Takes into account any unique aspects of the car (e.g., "Given the car's age and mileage, consider inspecting the transmission fluid and filter").

**Replace the parts if needed:**
- Part 1
- Part 2 
  ''';
  }

  Future<void> analyzeDiagnosis() async {
    String prompt = formattedPrompt(
      widget.summary,
      carDetails: widget.carDetails,
    );

    try {
      String? aiResponse = await ChatService().request(prompt);
      setState(() {
        response = aiResponse ?? "No response received. Please try again.";
      });
    } catch (error) {
      setState(() {
        response =
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Diagnosis Summary
            _buildSectionHeader("Concern Summary"),
            const SizedBox(height: 10),
            _buildContentCard(widget.summary),

            const SizedBox(height: 20),

            // Section: AI Analysis
            _buildSectionHeader("Diagnosis Analysis"),
            const SizedBox(height: 10),
            response == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Generating diagnosis analysis. Please wait...",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : _buildContentCard(response!),
          ],
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
