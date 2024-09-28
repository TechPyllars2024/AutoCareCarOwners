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
    required this.status
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
      'status': status
    };
  }

  // Creates a BookingModel instance from a Map (for deserialization)
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      carOwnerUid: map['carOwnerUid'] ?? '',
      serviceProviderUid: map['serviceProviderUid'],
      bookingId: map['bookingId'] ?? '',
      selectedService: List<String>.from(map['selectedService'] ?? []),
      bookingDate:map['bookingDate'],
      bookingTime: map['bookingTime'] ?? '',
      carBrand: map['carBrand'] ?? '',
      carModel: map['carModel'] ?? '',
      carYear: map['carYear'] ?? '',
      fuelType: map['fuelType'] ?? '',
      color: map['color'] ?? '',
      transmission: map['transmission'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'pending'
    );
  }
}
