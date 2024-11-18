class CarOwnerAddressModel {
  String houseNumberandStreet;
  String baranggay;
  String city;
  String province;
  String nearestLandmark;
  bool isDefault;

  CarOwnerAddressModel({
    required this.houseNumberandStreet,
    required this.baranggay,
    required this.city,
    required this.province,
    required this.nearestLandmark,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'houseNumberandStreet': houseNumberandStreet,
      'baranggay': baranggay,
      'city': city,
      'province': province,
      'nearestLandmark': nearestLandmark,
      'isDefault': isDefault,
    };
  }

  factory CarOwnerAddressModel.fromMap(Map<String, dynamic> map) {
    return CarOwnerAddressModel(
      houseNumberandStreet: map['houseNumberandStreet'],
      nearestLandmark: map['nearestLandmark'],
      baranggay: map['baranggay'],
      city: map['city'],
      province: map['province'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}
