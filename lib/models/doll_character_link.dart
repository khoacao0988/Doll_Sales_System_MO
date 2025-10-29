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
  final int status; // CORRECTED: Changed type from String to int
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
    linkID: json["linkID"],
    ownedDollID: json["ownedDollID"],
    userCharacterID: json["userCharacterID"],
    characterName: json["characterName"],
    status: json["status"], // Reads the int status
    isActive: json["isActive"] ?? false,
  );
}
