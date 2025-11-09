import 'dart:convert';

// Helper to safely parse an integer that might be a String
int _parseDynamicInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

class NotificationItem {
  final int notificationId;
  final int? userId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? topic;
  bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationItem({
    required this.notificationId,
    this.userId,
    required this.title,
    required this.body,
    required this.data,
    this.topic,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: _parseDynamicInt(json['notificationId']),
      userId: json['userId'] != null ? _parseDynamicInt(json['userId']) : null,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] is String ? jsonDecode(json['data']) : Map<String, dynamic>.from(json['data'] ?? {}),
      topic: json['topic'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
    );
  }
}
