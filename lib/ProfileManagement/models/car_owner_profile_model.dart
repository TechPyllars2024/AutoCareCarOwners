
class CarOwnerProfileModel {
  final String uid;
  final String name;
  final String email;
  final String profileImage;

  CarOwnerProfileModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  factory CarOwnerProfileModel.fromDocument(Map<String, dynamic> doc, String uid) {
    return CarOwnerProfileModel(
      uid: uid,
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      profileImage: doc['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profileImage': profileImage,
    };
  }
}