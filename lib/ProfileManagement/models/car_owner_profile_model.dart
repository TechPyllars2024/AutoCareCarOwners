class CarOwnerProfileModel {
  final String uid;
  final String profileId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String profileImage;

  CarOwnerProfileModel({
    required this.uid,
    required this.profileId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.profileImage,
  });

  // Factory method to create CarOwnerProfileModel from Firestore document
  factory CarOwnerProfileModel.fromDocument(
      Map<String, dynamic> doc, String uid) {
    return CarOwnerProfileModel(
      uid: uid,
      profileId: doc['profileId'] ?? '',
      firstName: doc['firstName'] ?? '',
      lastName: doc['lastName'] ?? '',
      phoneNumber: doc['phoneNumber'] ?? '',
      email: doc['email'] ?? 'No Email',
      profileImage: doc['profileImage'] ?? '',
    );
  }

  // Method to convert CarOwnerProfileModel to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'profileId': profileId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
    };
  }
}
