class CarDetailsModel {
  String brand;
  String model;
  int year;
  String color;
  String transmissionType;
  String fuelType;
  bool isDefault;

  CarDetailsModel({
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.transmissionType,
    required this.fuelType,
    this.isDefault = false
  });

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'transmissionType': transmissionType,
      'fuelType': fuelType,
      'isDefault': isDefault,
    };
  }

  factory CarDetailsModel.fromMap(Map<String, dynamic> map) {
    return CarDetailsModel(
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      color: map['color'],
      transmissionType: map['transmissionType'],
      fuelType: map['fuelType'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}
