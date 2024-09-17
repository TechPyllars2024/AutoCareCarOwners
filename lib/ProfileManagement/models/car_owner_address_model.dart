class CarOwnerAddressModel {
  String addressId;
  String profileId;
  String fullName;
  String phoneNumber;
  String street;
  String city;
  String country;
  bool isDefault;

  CarOwnerAddressModel({
    required this.addressId,
    required this.profileId,
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.country,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'addressId': addressId,
      'profileId': profileId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'country': country,
      'isDefault': isDefault,
    };
  }

  factory CarOwnerAddressModel.fromMap(Map<String, dynamic> map, String profileId) {
    return CarOwnerAddressModel(
      addressId: map['addressId'],
      profileId: profileId,
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      street: map['street'],
      city: map['city'],
      country: map['country'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}