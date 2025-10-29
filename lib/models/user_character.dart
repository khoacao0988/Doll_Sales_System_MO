import 'dart:convert';

// Parses the nested data object from the single-item API response
UserCharacter userCharacterFromJson(String str) {
  final Map<String, dynamic> jsonData = json.decode(str);
  return UserCharacter.fromJson(jsonData['data']);
}

class UserCharacter {
    final int userCharacterID;
    final int characterID;
    final String characterName;
    final int status; // Added status field as an int

    UserCharacter({
        required this.userCharacterID,
        required this.characterID,
        required this.characterName,
        required this.status,
    });

    factory UserCharacter.fromJson(Map<String, dynamic> json) => UserCharacter(
        userCharacterID: json["userCharacterID"],
        characterID: json["characterID"],
        characterName: json["characterName"],
        status: json["status"], // Reads the int status
    );
}
