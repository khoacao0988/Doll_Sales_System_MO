import 'dart:convert';

AuthResponse authResponseFromJson(String str) => AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
    final String accessToken;
    final DateTime expiresAt;
    final String refreshToken;
    final String username;
    final String role;

    AuthResponse({
        required this.accessToken,
        required this.expiresAt,
        required this.refreshToken,
        required this.username,
        required this.role,
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json["accessToken"],
        expiresAt: DateTime.parse(json["expiresAt"]),
        refreshToken: json["refreshToken"],
        username: json["username"],
        role: json["role"],
    );

    Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "expiresAt": expiresAt.toIso8601String(),
        "refreshToken": refreshToken,
        "username": username,
        "role": role,
    };
}
