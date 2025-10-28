import 'dart:convert';

// Parses a list of owned dolls from the list API response
List<OwnedDoll> ownedDollFromJson(String str) {
  final Map<String, dynamic> jsonData = json.decode(str);
  final List<dynamic> dollList = jsonData['data'] ?? [];
  return List<OwnedDoll>.from(dollList.map((x) => OwnedDoll.fromJson(x)));
}

// Parses a single owned doll from the single-item API response
OwnedDoll singleOwnedDollFromJson(String str) {
  final Map<String, dynamic> jsonData = json.decode(str);
  return OwnedDoll.fromJson(jsonData['data']);
}

class OwnedDoll {
    final int ownedDollId;
    final int userId;
    final int dollVariantId;
    final String dollVariantName;
    final String serialCode; // Added serialCode

    OwnedDoll({
        required this.ownedDollId,
        required this.userId,
        required this.dollVariantId,
        required this.dollVariantName,
        required this.serialCode, // Added to constructor
    });

    factory OwnedDoll.fromJson(Map<String, dynamic> json) => OwnedDoll(
        ownedDollId: json["ownedDollID"],
        userId: json["userID"],
        dollVariantId: json["dollVariantID"],
        dollVariantName: json["dollVariantName"],
        serialCode: json["serialCode"] ?? '', // Added with a fallback
    );
}
