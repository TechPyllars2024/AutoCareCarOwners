import 'package:autocare_carowners/ProfileManagement/screens/carDetails.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_addresses.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_booking.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_profile.dart';
import 'package:flutter/material.dart';

import '../../Authentication/Widgets/snackBar.dart';
import '../../Authentication/screens/login.dart';
import '../../Authentication/services/authentication_signout.dart';
import '../models/car_owner_profile_model.dart';
import '../services/profile_service.dart';

class CarOwnerMainProfile extends StatefulWidget {
  const CarOwnerMainProfile({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerMainProfile> createState() => _CarOwnerProfileState();
}

class _CarOwnerProfileState extends State<CarOwnerMainProfile> {
  CarOwnerProfileModel? profile;
  final CarOwnerProfileService _profileService = CarOwnerProfileService();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final fetchedProfile = await _profileService.fetchUserProfile();
    setState(() {
      profile = fetchedProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
        ),
        backgroundColor: Colors.grey.shade100,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                backgroundImage: profile?.profileImage.isNotEmpty == true
                    ? NetworkImage(profile!.profileImage)
                    : null,
                child: profile?.profileImage.isEmpty == true
                    ? const Icon(Icons.person, size: 100, color: Colors.black)
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Text(
                  '${profile?.firstName} ${profile?.lastName}' ?? '',
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                      child: ProfileMenuWidget(
                          title: "Profile Details",
                          icon: Icons.person,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CarOwnerProfile()),
                            );
                          },
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                      child: ProfileMenuWidget(
                          title: "Address",
                          icon: Icons.location_on,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CarOwnerAddress()),
                            );
                          },
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                      child: ProfileMenuWidget(
                          title: "Car Details",
                          icon: Icons.directions_car,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CarDetails()),
                            );
                          },
                      )
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                      child: ProfileMenuWidget(
                          title: "Bookings",
                          icon: Icons.event_note,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
                            );
                          },
                      )
                  ),
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ProfileMenuWidget(
                          title: "Logout",
                          icon: Icons.logout,
                        onPressed: () async {
                          try {
                            await AuthenticationMethodSignOut().signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          } catch (e) {
                            Utils.showSnackBar('Error Signing Out: $e');
                          }
                        },
                      )
                  ), //
                ],
              ),
            ), // Add onPressed function
          ],
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.endIcon = true,
    this.color,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final bool endIcon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.orange.shade900.withOpacity(0.1),
        ),
        child: Icon(icon, color: Colors.orange.shade900),
      ),
      title: Text(title, style: TextStyle(color: color ?? Colors.black)),
      trailing: endIcon? Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(Icons.arrow_forward_ios, size: 18.0, color: Colors.grey),
      ) : null,
    );
  }
}