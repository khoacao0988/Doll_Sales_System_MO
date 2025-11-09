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

// This function parses the response from the link API.
// It returns the first link object if it exists, otherwise null.
DollCharacterLink? dollCharacterLinkFromJson(String str) {
  final jsonData = json.decode(str);
  final dataList = jsonData['data'] as List;
  if (dataList.isEmpty) {
    return null;
  }
  return DollCharacterLink.fromJson(dataList.first);
}

class DollCharacterLink {
  final int linkID;
  final int ownedDollID;
  final int userCharacterID;
  final String characterName;
  final int status; 
  final bool isActive;

  DollCharacterLink({
    required this.linkID,
    required this.ownedDollID,
    required this.userCharacterID,
    required this.characterName,
    required this.status,
    required this.isActive,
  });

  // This factory parses the object inside the 'data' array.
  factory DollCharacterLink.fromJson(Map<String, dynamic> json) => DollCharacterLink(
    linkID: _parseDynamicInt(json["linkID"]),
    ownedDollID: _parseDynamicInt(json["ownedDollID"]),
    userCharacterID: _parseDynamicInt(json["userCharacterID"]),
    characterName: json["characterName"],
    status: _parseDynamicInt(json["status"]),
    isActive: json["isActive"] ?? false,
  );
}
