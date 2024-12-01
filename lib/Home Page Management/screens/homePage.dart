import 'package:autocare_carowners/Home%20Page%20Management/screens/carDiagnosis.dart';
import 'package:autocare_carowners/Home%20Page%20Management/screens/gasolineStation.dart';
import 'package:flutter/material.dart';

import '../widgets/card.dart';
import '../widgets/diagnosisField.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, this.child});

  final Widget? child;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text(
              'Auto',
              style:
                  TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
            ),
            Text(
              'Care',
              style: TextStyle(
                  fontWeight: FontWeight.w900, color: Colors.orange.shade900),
            ),
          ],
        ),
        backgroundColor: Colors.white70,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Background image
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/homepageBackground.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Text content
                  Padding(
                    padding: EdgeInsets.only(top: 40.0, left: 18.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "One",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: .5),
                          ),
                          Text(
                            "Destination.",
                            style: TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "All Car",
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: .5),
                          ),
                          Text(
                            "Solutions.",
                            style: TextStyle(
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 8, // Adjust the bottom position for overlap
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CardWidget(
                            icon: Icons.local_gas_station_rounded,
                            foregroundColor: Colors.orange.shade900,
                            title: 'Gasoline Station',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GasolineStation()),
                              );
                            },
                          ),
                          CardWidget(
                            icon: Icons.home_repair_service_rounded,
                            foregroundColor: Colors.orange.shade900,
                            title: 'Repair\nShops',
                            onTap: () {},
                          ),
                          CardWidget(
                            icon: Icons.warning_amber_rounded,
                            foregroundColor: Colors.orange.shade900,
                            title: 'Road Assistance',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: DiagnosisField(
                title: 'DIAGNOSE MY CAR',
                subtitle:
                    'Not sure of what is wrong with your car? Let us help you through our diagnosis.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Cardiagnosis()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
