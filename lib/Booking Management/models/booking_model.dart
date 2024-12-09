class BookingModel {
  String carOwnerUid;
  String serviceProviderUid;
  String bookingId;
  List<String> selectedService;
  String bookingDate;
  String bookingTime;
  String carBrand;
  String carModel;
  String carYear;
  String fuelType;
  String color;
  String transmission;
  DateTime createdAt;
  String status;
  String? phoneNumber;
  String fullName;
  double totalPrice;
  String? shopName;
  String? shopAddress;
  bool isFeedbackSubmitted;
  double? latitude;
  double? longitude;

  BookingModel({
    required this.carOwnerUid,
    required this.serviceProviderUid,
    required this.bookingId,
    required this.selectedService,
    required this.bookingDate,
    required this.bookingTime,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    required this.fuelType,
    required this.color,
    required this.transmission,
    required this.createdAt,
    required this.status,
    this.phoneNumber,
    required this.fullName,
    required this.totalPrice,
    this.shopName,
    this.shopAddress,
    required this.isFeedbackSubmitted,
    required this.latitude,
    required this.longitude
  });

  // Converts a BookingModel instance to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'carOwnerUid': carOwnerUid,
      'serviceProviderUid': serviceProviderUid,
      'bookingId': bookingId,
      'selectedService': selectedService,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'carBrand': carBrand,
      'carModel': carModel,
      'carYear': carYear,
      'fuelType': fuelType,
      'color': color,
      'transmission': transmission,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'phoneNumber': phoneNumber,
      'totalPrice': totalPrice,
      'fullName': fullName,
      'shopName': shopName,
      'shopAddress': shopAddress,
      'isFeedbackSubmitted': isFeedbackSubmitted,
      'latitude': latitude,
      'longitude': longitude
    };
  }

  // Creates a BookingModel instance from a Map (for deserialization)
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      carOwnerUid: map['carOwnerUid'] ?? '',
      serviceProviderUid: map['serviceProviderUid'] ?? '',
      bookingId: map['bookingId'] ?? '',
      selectedService: List<String>.from(map['selectedService'] ?? []),
      bookingDate: map['bookingDate'] ?? '',
      bookingTime: map['bookingTime'] ?? '',
      carBrand: map['carBrand'] ?? '',
      carModel: map['carModel'] ?? '',
      carYear: map['carYear'] ?? '',
      fuelType: map['fuelType'] ?? '',
      color: map['color'] ?? '',
      transmission: map['transmission'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      phoneNumber: map['phoneNumber'],
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      fullName: map['fullName'] ?? '',
      shopAddress: map['shopAddress'] ?? '',
      shopName: map['shopName'] ?? '',
      isFeedbackSubmitted: map['isFeedbackSubmitted'] ?? false,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0
    );
  }
}
