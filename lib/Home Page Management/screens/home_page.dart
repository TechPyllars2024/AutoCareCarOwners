import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
        actions: const [],
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0, // Align to the left
            top: 0,  // Start from the top
            bottom: 0,  // Extend to the bottom
            child: Container(
              width: MediaQuery.of(context).size.width * 0.25,
              color: const Color(0xFFC2A482),  // Color code for the rectangle
            ),
          ),
          // Main content layered on top
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main text
                  const Text(
                    'One Destination,\nAll Car Solutions.',
                    style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFae7204),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Car image
                  Center(
                    child: Image.asset(
                      'assets/images/car home.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Buttons for options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOptionCard(Icons.local_gas_station, 'Gasoline\nStations', (){
                        print("Clicked");
                      }),
                      _buildOptionCard(Icons.build, 'Repair\nShops', (){
                        print("Clicked");
                      }),
                      _buildOptionCard(Icons.warning, 'Road\nAssistance', (){
                        print("Clicked");
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Diagnose my car section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Not sure of what's wrong with your car? Let us help you through our diagnosis.",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            print('Clicked');
                          },
                          style: ElevatedButton.styleFrom(),
                          child: const Text(
                              "DIAGNOSE MY CAR",
                              style: TextStyle(color: Colors.orange)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build vertical buttons
  Widget _buildOptionCard(IconData icon, String text, Function() onTap) {
    return ElevatedButton(
      onPressed: onTap, // Callback for button press
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.white, // Button text/icon color
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        elevation: 5, // Shadow for the button
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.black), // Larger icon
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
