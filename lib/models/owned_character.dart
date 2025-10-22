import 'dart:convert';

// This function now correctly parses a list nested inside a 'data' property.
List<OwnedCharacter> ownedCharacterFromJson(String str) {
  final Map<String, dynamic> jsonData = json.decode(str);
  final List<dynamic> characterList = jsonData['data'] ?? []; // Use a fallback for safety
  return List<OwnedCharacter>.from(characterList.map((x) => OwnedCharacter.fromJson(x)));
}

class OwnedCharacter {
    final int characterId;
    final String characterName;
    final String? description;
    final String? imageUrl;

    OwnedCharacter({
        required this.characterId,
        required this.characterName,
        this.description,
        this.imageUrl,
    });

    // Cleaned up factory now that the correct API is being called.
    factory OwnedCharacter.fromJson(Map<String, dynamic> json) {
        return OwnedCharacter(
            characterId: json["characterID"], 
            characterName: json["characterName"],
            description: json["description"], // Will be null if not in JSON, which is correct
            imageUrl: json["imageUrl"],       // Will be null if not in JSON, which is correct
        );
    }
}
