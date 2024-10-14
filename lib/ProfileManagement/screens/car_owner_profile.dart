import 'package:autocare_carowners/Authentication/services/authentication_signout.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_address_model.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_car_details.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_addresses.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_booking.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_edit_profile.dart';
import 'package:autocare_carowners/Authentication/screens/login.dart';
import 'package:flutter/material.dart';
import '../../Authentication/Widgets/snackBar.dart';
import '../services/profile_service.dart';

class CarOwnerProfile extends StatefulWidget {
  const CarOwnerProfile({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerProfile> createState() => _CarOwnerProfileState();
}

class _CarOwnerProfileState extends State<CarOwnerProfile> {
  CarOwnerProfileModel? profile;
  CarOwnerAddressModel? defaultAddress;
  String? userEmail;
  final CarOwnerProfileService _profileService =
      CarOwnerProfileService(); // Instantiate the service

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserEmail();
  }

  Future<void> _fetchUserProfile() async {
    final fetchedProfile = await _profileService.fetchUserProfile();
    setState(() {
      profile = fetchedProfile;
    });
  }

  Future<void> _fetchUserEmail() async {
    final email = await _profileService.fetchUserEmail();
    setState(() {
      userEmail = email;
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
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          IconButton(
            onPressed: () async {
              if (profile != null) {
                final updatedProfile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarOwnerEditProfileScreen(
                      currentUser: profile!,
                    ),
                  ),
                );
                if (updatedProfile != null) {
                  setState(() {
                    profile = updatedProfile;
                  });
                }
              }
            },
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade900, // Set the background color to orange
                borderRadius: BorderRadius.circular(12.0), // Rounded edges
              ),
              padding: const EdgeInsets.all(6.0), // Optional: Add some padding for better aesthetics
              child: const Center( // Center the icon
                child: Icon(
                  Icons.edit,
                  color: Colors.white, // Set the icon color to white
                  size: 30,
                ),
              ),
            ),
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                width: 180, // Adjust width for border thickness
                height: 180, // Adjust height for border thickness
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.orange.shade900, // Border color
                    width: 1, // Border width
                  ),
                ),
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  backgroundImage: profile?.profileImage.isNotEmpty == true
                      ? NetworkImage(profile!.profileImage)
                      : null,
                  child: profile?.profileImage.isEmpty == true
                      ? const Icon(Icons.person, size: 80, color: Colors.black)
                      : null,
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Center(
                    child: Text(
                      '${profile?.firstName} ${profile?.lastName}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 25),
                  child: profile?.phoneNumber != null && profile!.phoneNumber.isNotEmpty
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone, // Phone icon
                        size: 20,
                        color: Colors.orange.shade900,
                      ),
                      const SizedBox(width: 10), // Adds space between the icon and text
                      Text(
                        profile?.phoneNumber ?? 'No phone number available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  )
                      : Container(), // If phone number is null, display an empty container
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 25) ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                       Icon(
                        Icons.email_rounded, // Email icon
                        size: 20,
                        color: Colors.orange.shade900,
                      ),
                      const SizedBox(
                          width: 10), // Adds space between the icon and text
                      Text(
                        userEmail ?? 'No available Email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // fetching defualt address
                StreamBuilder<CarOwnerAddressModel?>(
                  stream: _profileService.getDefaultAddress(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text('Error fetching default address.');
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final defaultAddress = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, left: 25, right: 25, bottom: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_sharp,
                              size: 20,
                              color: Colors.orange.shade900,
                            ),
                            const SizedBox(width: 8), // Space between icon and text
                            Flexible(
                              child: Text(
                                '${defaultAddress.houseNumberandStreet}, ${defaultAddress.baranggay}, ${defaultAddress.city}, ${defaultAddress.province}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.visible, // Allows text to wrap
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),

                const Divider(
                  color: Colors.grey,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
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
                            title: "My Bookings",
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
                ),
              ],
            ),
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