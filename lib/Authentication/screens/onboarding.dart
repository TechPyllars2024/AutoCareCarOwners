import 'package:autocare_carowners/Authentication/screens/onboardingPage1.dart';
import 'package:autocare_carowners/Authentication/screens/onboardingPage2.dart';
import 'package:autocare_carowners/Authentication/screens/onboardingPage3.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:autocare_carowners/ProfileManagement/services/profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../ProfileManagement/screens/car_owner_complete_profile.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int currentPageIndex = 0;
  final user = FirebaseAuth.instance.currentUser;
  CarOwnerProfileModel? profile;
  bool isLoading = true;  // New state for tracking loading

  Future<void> _fetchUserProfile() async {
    final fetchedProfile = await CarOwnerProfileService().fetchUserProfile();
    setState(() {
      profile = fetchedProfile;
      isLoading = false;  // Set loading to false once the profile is fetched
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _controller.addListener(() {
      setState(() {
        currentPageIndex = _controller.page?.round() ?? 0; // Update the current page index
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index; // Update the current page index
              });
            },
            children: [
              const Onboardingpage1(),
              const Onboardingpage2(),
              isLoading
                  ? const Center(child: CircularProgressIndicator())  // Show loading spinner
                  : CarOwnerCompleteProfileScreen(currentUser: profile!),  // Only load this when profile is not null
              const Onboardingpage3(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                currentPageIndex == 0
                    ? const Text("      ") // Don't show "pre" if on first page
                    : GestureDetector(
                  onTap: () {
                    _controller.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                  },
                  child: const Icon(Icons.navigate_before),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: ExpandingDotsEffect(
                    dotColor: Colors.black54, // Inactive dot color
                    activeDotColor: Colors.orange.shade300, // Active dot color
                    dotHeight: 8.0,
                    dotWidth: 8.0,
                  ),
                ),
                (currentPageIndex == 2 || currentPageIndex == 3)
                    ? const Text("      ") // Don't show the next icon on the third page or the last page
                    : GestureDetector(
                  onTap: () {
                    _controller.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                  },
                  child: const Icon(Icons.navigate_next),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
