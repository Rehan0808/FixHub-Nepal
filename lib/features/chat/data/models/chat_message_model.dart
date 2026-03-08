class ChatMessageModel {
  final String id;
  final String message;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      message: json['message'] ?? json['content'] ?? '',
      senderId: json['senderId'] ?? json['sender']?['_id'] ?? json['userId'] ?? '',
      senderName: json['senderName'] ?? json['sender']?['fullName'] ?? json['userName'] ?? 'User',
      isAdmin: json['isAdmin'] ?? json['role'] == 'admin' ?? json['sender']?['role'] == 'admin' ?? false,
      timestamp: json['timestamp'] != null 
          ? (json['timestamp'] is String 
              ? DateTime.parse(json['timestamp'])
              : DateTime.fromMillisecondsSinceEpoch(json['timestamp']))
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'isAdmin': isAdmin,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Factory for creating local messages
  factory ChatMessageModel.createLocal({
    required String message,
    required String senderId,
    required String senderName,
    bool isAdmin = false,
  }) {
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      senderId: senderId,
      senderName: senderName,
      isAdmin: isAdmin,
      timestamp: DateTime.now(),
    );
  }
}
