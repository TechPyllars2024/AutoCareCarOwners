class CarOwnerAddressModel {
  String fullName;
  String phoneNumber;
  String street;
  String baranggay;
  String city;
  String province;
  bool isDefault;

  CarOwnerAddressModel({
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.baranggay,
    required this.city,
    required this.province,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'street': street,
      'baranggay': baranggay,
      'city': city,
      'province': province,
      'isDefault': isDefault,
    };
  }

  factory CarOwnerAddressModel.fromMap(Map<String, dynamic> map) {
    return CarOwnerAddressModel(
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      street: map['street'],
      baranggay: map['baranggay'],
      city: map['city'],
      province: map['province'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}