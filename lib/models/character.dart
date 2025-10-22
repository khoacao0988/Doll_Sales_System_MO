import 'dart:convert';

// A function to parse the JSON for a single detailed character
Character characterFromJson(String str) => Character.fromJson(json.decode(str));

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
        characterId: json["characterId"],
        name: json["name"],
        image: json["image"],
        ageRange: json["ageRange"],
        personality: json["personality"],
        description: json["description"],
        isActive: json["isActive"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );
}
