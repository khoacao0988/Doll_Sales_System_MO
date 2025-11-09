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

List<UserCharacter> userCharacterFromJson(String str) => List<UserCharacter>.from(json.decode(str).map((x) => UserCharacter.fromJson(x)));

class UserCharacter {
    final int userCharacterID;
    final int userID;
    final int characterID;
    final String characterName;
    final String? characterImage;
    final int status;
    final bool isActive;

    UserCharacter({
        required this.userCharacterID,
        required this.userID,
        required this.characterID,
        required this.characterName,
        this.characterImage,
        required this.status,
        required this.isActive,
    });

    factory UserCharacter.fromJson(Map<String, dynamic> json) => UserCharacter(
        userCharacterID: _parseDynamicInt(json["userCharacterID"]),
        userID: _parseDynamicInt(json["userID"]),
        characterID: _parseDynamicInt(json["characterID"]),
        characterName: json["characterName"],
        characterImage: json["characterImage"],
        status: _parseDynamicInt(json["status"]),
        isActive: json["isActive"] ?? false,
    );
}
