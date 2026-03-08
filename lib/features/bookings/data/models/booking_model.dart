class BookingModel {
  final String id;
  final String customerId;
  final String serviceId;
  final String bikeModel;
  final String customerName;
  final String serviceType;
  final String status; // "Pending", "In Progress", "Completed", "Cancelled"
  final DateTime date;
  final String notes;
  final double totalCost;
  final bool discountApplied;
  final double discountAmount;
  final double finalAmount;
  final String paymentStatus; // "Pending", "Paid", "Failed"
  final String paymentMethod; // "COD", "Khalti", "eSewa", "Not Selected"
  final bool isPaid;
  final int pointsAwarded;
  final bool reviewSubmitted;
  final bool requestedPickupDropoff;
  final String pickupAddress;
  final String dropoffAddress;
  final double pickupDropoffDistance;
  final double pickupDropoffCost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String serviceImage; // admin-uploaded image path for the service

  BookingModel({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.bikeModel,
    required this.customerName,
    required this.serviceType,
    required this.status,
    required this.date,
    this.notes = '',
    required this.totalCost,
    this.discountApplied = false,
    this.discountAmount = 0,
    required this.finalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.isPaid = false,
    this.pointsAwarded = 0,
    this.reviewSubmitted = false,
    this.requestedPickupDropoff = false,
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.pickupDropoffDistance = 0,
    this.pickupDropoffCost = 0,
    required this.createdAt,
    required this.updatedAt,
    this.serviceImage = '',
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      customerId: json['customer'] ?? '',
      serviceId: json['service'] ?? '',
      bikeModel: json['bikeModel'] ?? '',
      customerName: json['customerName'] ?? '',
      serviceType: json['serviceType'] ?? '',
      status: json['status'] ?? 'Pending',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      notes: json['notes'] ?? '',
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      discountApplied: json['discountApplied'] ?? false,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      paymentMethod: json['paymentMethod'] ?? 'Not Selected',
      isPaid: json['isPaid'] ?? false,
      pointsAwarded: json['pointsAwarded'] ?? 0,
      reviewSubmitted: json['reviewSubmitted'] ?? false,
      requestedPickupDropoff: json['requestedPickupDropoff'] ?? false,
      pickupAddress: json['pickupAddress'] ?? '',
      dropoffAddress: json['dropoffAddress'] ?? '',
      pickupDropoffDistance: (json['pickupDropoffDistance'] ?? 0).toDouble(),
      pickupDropoffCost: (json['pickupDropoffCost'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      serviceImage: json['serviceImage'] ??
          (json['service'] is Map ? json['service']['image'] : null) ??
          '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customer': customerId,
      'service': serviceId,
      'bikeModel': bikeModel,
      'customerName': customerName,
      'serviceType': serviceType,
      'status': status,
      'date': date.toIso8601String(),
      'notes': notes,
      'totalCost': totalCost,
      'discountApplied': discountApplied,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'pointsAwarded': pointsAwarded,
      'reviewSubmitted': reviewSubmitted,
      'requestedPickupDropoff': requestedPickupDropoff,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'pickupDropoffDistance': pickupDropoffDistance,
      'pickupDropoffCost': pickupDropoffCost,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isPending => status == 'Pending';
  bool get isInProgress => status == 'In Progress';
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';

  String get statusColor {
    switch (status) {
      case 'In Progress':
        return 'warning';
      case 'Completed':
        return 'success';
      case 'Cancelled':
        return 'error';
      default:
        return 'info';
    }
  }
}
