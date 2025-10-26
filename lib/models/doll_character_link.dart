import 'dart:convert';

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
  final String status;
  final bool isActive; // Added isActive field

  DollCharacterLink({
    required this.linkID,
    required this.ownedDollID,
    required this.userCharacterID,
    required this.characterName,
    required this.status,
    required this.isActive, // Added to constructor
  });

  // This factory parses the object inside the 'data' array.
  factory DollCharacterLink.fromJson(Map<String, dynamic> json) => DollCharacterLink(
    linkID: json["linkID"],
    ownedDollID: json["ownedDollID"],
    userCharacterID: json["userCharacterID"],
    characterName: json["characterName"],
    status: json["status"],
    isActive: json["isActive"] ?? false, // Added isActive field with a fallback
  );
}
