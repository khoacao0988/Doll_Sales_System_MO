import 'dart:convert';

class User {
    final int userID;
    final String userName;
    final String? phones;
    final String email;
    final String status;
    final String role;
    final bool isDeleted;
    final DateTime createdAt;

    User({
        required this.userID,
        required this.userName,
        this.phones,
        required this.email,
        required this.status,
        required this.role,
        required this.isDeleted,
        required this.createdAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        userID: json["userID"],
        userName: json["userName"],
        phones: json["phones"],
        email: json["email"],
        status: json["status"],
        role: json["role"],
        isDeleted: json["isDeleted"],
        createdAt: DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "userID": userID,
        "userName": userName,
        "phones": phones,
        "email": email,
        "status": status,
        "role": role,
        "isDeleted": isDeleted,
        "createdAt": createdAt.toIso8601String(),
    };
}
