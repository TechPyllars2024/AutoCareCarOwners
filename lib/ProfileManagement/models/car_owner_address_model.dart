
class CarOwnerAddressModel {
  String fullName;
  String phoneNumber;
  String street;
  String city;
  String country;
  bool isDefault;

  CarOwnerAddressModel({
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.country,
    this.isDefault = false,
  });
}