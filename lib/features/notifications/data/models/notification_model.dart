class NotificationModel {
  final String id;
  final String message;
  final String type; // "booking" | "status" | "chat" | "general"
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({bool? read}) {
    return NotificationModel(
      id: id,
      message: message,
      type: type,
      read: read ?? this.read,
      createdAt: createdAt,
    );
  }
}
