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

// A function to parse the JSON for a single detailed character
Character characterFromJson(String str) {
  final jsonData = json.decode(str);
  // Handle cases where the character data is nested under a "data" key
  if (jsonData.containsKey('data') && jsonData['data'] is Map) {
    return Character.fromJson(jsonData['data']);
  }
  return Character.fromJson(jsonData);
}

class Character {
    final int characterId;
    final String name;
    final String? image;
    final int? ageRange;
    final String? personality;
    final String? description;
    final bool? isActive;
    final DateTime? createdAt;

    Character({
        required this.characterId,
        required this.name,
        this.image,
        this.ageRange,
        this.personality,
        this.description,
        this.isActive,
        this.createdAt,
    });

    factory Character.fromJson(Map<String, dynamic> json) => Character(
        characterId: _parseDynamicInt(json["characterId"]),
        name: json["name"],
        image: json["image"],
        ageRange: _parseDynamicInt(json["ageRange"]),
        personality: json["personality"],
        description: json["description"],
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );
}
