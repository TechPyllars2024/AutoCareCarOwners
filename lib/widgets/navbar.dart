import 'package:autocare_carowners/screens/car_owner_directory.dart';
import 'package:autocare_carowners/screens/car_owner_message.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:autocare_carowners/screens/car_owner_profile.dart';
import 'package:autocare_carowners/screens/car_owner_home.dart';


class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
//State class
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = [
    CarOwnerHome(),
    CarOwnerMessage(),
    CarOwnerDirectory(),
    CarOwnerProfile(),


  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.grey.shade300,
          key: _bottomNavigationKey,
          items: <Widget>[
            Icon(Icons.home, size: 30),
            Icon(Icons.message, size: 30),
            Icon(Icons.directions_car, size: 30),
            Icon(Icons.person, size: 30),
          ],
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
      body:
      _screens[_page], // This will display the selected screen
    );
  }
}

