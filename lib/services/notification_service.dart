import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:second/models/pagination_info.dart';
import '../models/notification_item.dart';
import 'session_service.dart';

class NotificationResponse {
  final List<NotificationItem> items;
  final PaginationInfo pagination;

  NotificationResponse({required this.items, required this.pagination});

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      items: (json['items'] as List).map((item) => NotificationItem.fromJson(item)).toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const String _baseUrl = 'https://dollaistore-api-dxdggjazgpckh2cc.japaneast-01.azurewebsites.net';

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();
    // You can add foreground message handling here if needed
  }

  Future<String?> getFcmToken() async {
    try {
      final String? fcmToken = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('🔥 FCM TOKEN = $fcmToken');
      }
      return fcmToken;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
      }
      return null;
    }
  }

  // Get list of notifications
  Future<NotificationResponse> getNotifications({
    bool onlyUnread = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = SessionService().authResponse?.accessToken;
    if (token == null) throw Exception('Not authenticated');

    final queryParams = {
      'onlyUnread': onlyUnread.toString(),
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    final uri = Uri.parse('$_baseUrl/api/notifications').replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return NotificationResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else {
      throw Exception('Failed to load notifications: ${response.statusCode}');
    }
  }

  // Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    final token = SessionService().authResponse?.accessToken;
    if (token == null) throw Exception('Not authenticated');
    
    final uri = Uri.parse('$_baseUrl/api/notifications/$notificationId/read');

    final response = await http.patch(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 204;
  }
}
