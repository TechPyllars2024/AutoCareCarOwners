import 'package:autocare_carowners/screens/car_owner_car_profile.dart';
import 'package:autocare_carowners/screens/car_owner_directory.dart';
import 'package:autocare_carowners/screens/car_owner_edit_profile.dart';
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
    CarOwnerEditProfile(),
    CarOwnerCarProfile(),


  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.grey.shade300,
          key: _bottomNavigationKey,
          items: <Widget>[
            Icon(Icons.home, size: 30, color: _page == 0 ? Colors.orange : Colors.black),
            Icon(Icons.message, size: 30, color: _page == 1 ? Colors.orange : Colors.black),
            Icon(Icons.directions_car, size: 30, color: _page == 2 ? Colors.orange : Colors.black),
            Icon(Icons.person, size: 30, color: _page == 3 ? Colors.orange : Colors.black),



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

