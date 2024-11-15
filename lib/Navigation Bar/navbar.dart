import 'package:autocare_carowners/Home%20Page%20Management/screens/home_page.dart';
import 'package:autocare_carowners/Messages%20Management/screens/messages.dart';
import 'package:autocare_carowners/Service%20Directory%20Management/screens/service_directory.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../ProfileManagement/screens/car_owner_profile.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key, this.child});

  final Widget? child;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
//State class
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = [
    const HomePageScreen(),
    const CarOwnerMessagesScreen(),
    const ServiceDirectoryScreen(),
    const CarOwnerProfile()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.grey.shade100,
        color: Colors.white,
        key: _bottomNavigationKey,
        items: <Widget>[
          Icon(Icons.home,
              size: 25,
              color:
                  _page == 0 ? Colors.orange.shade900 : Colors.grey.shade700),
          Icon(Icons.message,
              size: 25,
              color:
                  _page == 1 ? Colors.orange.shade900 : Colors.grey.shade700),
          Icon(Icons.directions_car,
              size: 25,
              color:
                  _page == 2 ? Colors.orange.shade900 : Colors.grey.shade700),
          Icon(Icons.person,
              size: 25,
              color:
                  _page == 3 ? Colors.orange.shade900 : Colors.grey.shade700),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        index: _page, // Ensure the selected item is highlighted
      ),
      body: _screens[_page], // Display the selected screen
    );
  }
}
