import 'dart:convert';

class User {
    final int userID;
    final String userName;
    final String? fullName;
    final String? phones;
    final String email;
    final int? age;
    final int status;
    final String role;
    final DateTime createdAt;

    User({
        required this.userID,
        required this.userName,
        this.fullName,
        this.phones,
        required this.email,
        this.age,
        required this.status,
        required this.role,
        required this.createdAt,
    });

    // Helper function to parse a value that could be an int or a String
    static int _parseDynamicInt(dynamic value, {int defaultValue = 0}) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    // This factory is now fully robust for both userID and status.
    factory User.fromJson(Map<String, dynamic> json) {
      return User(
        userID: _parseDynamicInt(json["userID"] ?? json["id"]), // Handles both "userID" and "id", int or String
        userName: json["userName"],
        fullName: json["fullName"],
        phones: json["phones"],
        email: json["email"],
        age: _parseDynamicInt(json["age"], defaultValue: 0), // Also make age robust
        status: _parseDynamicInt(json["status"]), // Robust parsing for status
        role: json["role"],
        createdAt: DateTime.parse(json["createdAt"]),
      );
    }

    Map<String, dynamic> toJson() => {
        "userID": userID,
        "userName": userName,
        "fullName": fullName,
        "phones": phones,
        "email": email,
        "age": age,
        "status": status,
        "role": role,
        "createdAt": createdAt.toIso8601String(),
    };
}
