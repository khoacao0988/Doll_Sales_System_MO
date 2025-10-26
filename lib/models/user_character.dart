import 'dart:convert';

// Parses a single UserCharacter object from a JSON string
UserCharacter userCharacterFromJson(String str) => UserCharacter.fromJson(json.decode(str));

class UserCharacter {
    final int userCharacterID;
    final int characterID;

    UserCharacter({
        required this.userCharacterID,
        required this.characterID,
    });

    factory UserCharacter.fromJson(Map<String, dynamic> json) => UserCharacter(
        userCharacterID: json["userCharacterID"],
        characterID: json["characterID"],
    );
}
