class CarDetailsModel {
  String carDetailId;
  String profileId;
  String brand;
  String model;
  int year;
  String color;
  String transmissionType;
  String fuelType;

  CarDetailsModel({
    required this.carDetailId,
    required this.profileId,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.transmissionType,
    required this.fuelType,
  });

  Map<String, dynamic> toMap() {
    return {
      'carDetailId': carDetailId,
      'profileId': profileId,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
    };
  }

  factory CarDetailsModel.fromMap(Map<String, dynamic> map, String profileId) {
    return CarDetailsModel(
      carDetailId: map['carDetailId'],
      profileId: profileId,
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      color: map['color'],
      transmissionType: map['transmissionType'],
      fuelType: map['fuelType'],
    );
  }
}
