class CarOwnerProfileModel {
  final String uid;
  final String profileId;
  final String name;
  final String email;
  final String profileImage;

  CarOwnerProfileModel({
    required this.uid,
    required this.profileId,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  // Factory method to create CarOwnerProfileModel from Firestore document
  factory CarOwnerProfileModel.fromDocument(Map<String, dynamic> doc, String uid) {
    return CarOwnerProfileModel(
      uid: uid,
      profileId: doc['profileId'] ?? '',
      name: doc['name'] ?? 'Unnamed',
      email: doc['email'] ?? 'No Email',
      profileImage: doc['profileImage'] ?? '',
    );
  }

  // Method to convert CarOwnerProfileModel to a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'profileId': profileId,
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }
}
