import 'package:flutter/material.dart';

class CallingScreen extends StatefulWidget {
  @override
  _CallingScreenState createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[700],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Caller Info
            Column(
              children: [
                const SizedBox(height: 150),
                const CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                      'https://via.placeholder.com/150'), // Replace with caller image
                ),
                const SizedBox(height: 20),
                const Text(
                  'John Doe', // Caller Name
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '00:02:35', // Call duration
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),

            // Call Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Mute Button
                  Column(
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.grey[800],
                        onPressed: () {
                          // Handle mute action
                        },
                        child: const Icon(Icons.mic_off, color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                  // Speaker Button
                  Column(
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.grey[800],
                        onPressed: () {
                          // Handle speaker action
                        },
                        child: const Icon(Icons.volume_up, color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                  // End Call Button
                  Column(
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () {
                          Navigator.pop(context); // End call and go back
                        },
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}