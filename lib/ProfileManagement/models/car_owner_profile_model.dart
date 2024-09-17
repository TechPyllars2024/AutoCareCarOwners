class CarOwnerProfileModel {
  final String profileId;
  final String uid;
  final String name;
  final String email;
  final String profileImage;

  CarOwnerProfileModel({
    required this.profileId,
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  factory CarOwnerProfileModel.fromDocument(Map<String, dynamic> doc, String uid) {
    return CarOwnerProfileModel(
      uid: uid,
      profileId: doc['profileId'],
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      profileImage: doc['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }
}