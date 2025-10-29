import 'dart:convert';

class User {
    final int userID;
    final String userName;
    final String? fullName;
    final String? phones;
    final String email;
    final int? age; // Added age
    final int status;
    final String role;
    final DateTime createdAt;

    User({
        required this.userID,
        required this.userName,
        this.fullName,
        this.phones,
        required this.email,
        this.age, // Added to constructor
        required this.status,
        required this.role,
        required this.createdAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        userID: json["userID"], 
        userName: json["userName"], 
        fullName: json["fullName"],
        phones: json["phones"],
        email: json["email"],
        age: json["age"], // Read age
        status: json["status"], 
        role: json["role"],
        createdAt: DateTime.parse(json["createdAt"]),
    );

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
