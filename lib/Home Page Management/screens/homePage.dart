import 'package:autocare_carowners/Home%20Page%20Management/screens/gasolineStation.dart';
import 'package:flutter/material.dart';

import '../widgets/card.dart';
import '../widgets/diagnosisField.dart';
//import '../widgets/gasolineStationMap.dart';



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
          title:  Row(
            children: [
              const Text(
                'Auto',
                style: TextStyle(fontWeight: FontWeight.w900,color: Colors.black),
              ),
              Text(
                'Care',
                style: TextStyle(fontWeight: FontWeight.w900,color: Colors.orange.shade900),
              ),
            ],
          ),
          backgroundColor: Colors.grey.shade100,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CardWidget(
                      icon: Icons.local_gas_station_rounded,
                      title: 'Gasoline Station',

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GasolineStation()),
                        );
                      },
                    ),
                    CardWidget(
                      icon: Icons.home_repair_service_rounded,
                      title: 'Repair\nShops',

                      onTap: () {
                      },
                    ),
                    CardWidget(
                      icon: Icons.warning_amber_rounded,
                      title: 'Road Assistance',

                      onTap: () {

                      },
                    ),
                  ],
                ),
                DiagnosisField(
                  title: 'DIAGNOSE MY CAR',
                  subtitle: 'Not sure of what is wrong with your car? Let us help you through our diagnosis.' ,
                  onTap: () {

                  },
                ),

              ],
            ),
          ),

        )
    );
  }
}
