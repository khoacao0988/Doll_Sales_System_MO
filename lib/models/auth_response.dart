import 'dart:convert';
import 'user.dart';

AuthResponse authResponseFromJson(String str) => AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
    final String accessToken;
    final DateTime expiresAt;
    final String refreshToken;
    final int? userId;
    final String? username;
    final String? role;
    final User? user;

    AuthResponse({
        required this.accessToken,
        required this.expiresAt,
        required this.refreshToken,
        this.userId,
        this.username,
        this.role,
        this.user,
    });

    // This factory is now robust and can handle different types for userId.
    factory AuthResponse.fromJson(Map<String, dynamic> json) {
      dynamic rawUserId = json["userId"];
      int? parsedUserId;
      if (rawUserId is int) {
        parsedUserId = rawUserId;
      } else if (rawUserId is String) {
        parsedUserId = int.tryParse(rawUserId);
      }

      return AuthResponse(
        accessToken: json["accessToken"],
        expiresAt: DateTime.parse(json["expiresAt"]),
        refreshToken: json["refreshToken"],
        userId: parsedUserId, 
        username: json["username"],
        role: json["role"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );
    }

    Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "expiresAt": expiresAt.toIso8601String(),
        "refreshToken": refreshToken,
        "userId": userId,
        "username": username,
        "role": role,
        "user": user?.toJson(),
    };
}
