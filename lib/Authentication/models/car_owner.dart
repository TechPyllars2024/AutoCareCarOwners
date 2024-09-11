class UserModel {
  final String uid;
  final String name;
  final String email;
  final List<String> roles; // Roles like ['car_owner', 'service_provider']

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.roles,
  });

  // Convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'roles': roles,
    };
  }

  // Create UserModel from a Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      roles: List<String>.from(map['roles'] ?? []),
    );
  }
}
