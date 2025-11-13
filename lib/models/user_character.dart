import 'dart:convert';

// Helper to safely parse a DateTime from a String
DateTime _parseDateTime(String? dateString) {
  if (dateString == null) {
    // Return a date in the past if null, making it invalid
    return DateTime.now().subtract(const Duration(days: 1));
  }
  return DateTime.parse(dateString);
}

List<UserCharacter> userCharacterFromJson(String str) => List<UserCharacter>.from(json.decode(str).map((x) => UserCharacter.fromJson(x)));

class UserCharacter {
    final int userCharacterID;
    final int userID;
    final String userName;
    final int characterID;
    final String characterName;
    final int packageId;
    final String packageName;
    final DateTime startAt;
    final DateTime endAt;
    final bool autoRenew;
    final String status;
    final String statusDisplay;

    UserCharacter({
        required this.userCharacterID,
        required this.userID,
        required this.userName,
        required this.characterID,
        required this.characterName,
        required this.packageId,
        required this.packageName,
        required this.startAt,
        required this.endAt,
        required this.autoRenew,
        required this.status,
        required this.statusDisplay,
    });

    factory UserCharacter.fromJson(Map<String, dynamic> json) => UserCharacter(
        userCharacterID: json["userCharacterID"] ?? 0,
        userID: json["userID"] ?? 0,
        userName: json["userName"] ?? 'Unknown',
        characterID: json["characterID"] ?? 0,
        characterName: json["characterName"] ?? 'Unknown Character',
        packageId: json["packageId"] ?? 0,
        packageName: json["packageName"] ?? 'Unknown Package',
        startAt: _parseDateTime(json["startAt"]),
        endAt: _parseDateTime(json["endAt"]),
        autoRenew: json["autoRenew"] ?? false,
        status: json["status"] ?? 'Inactive',
        statusDisplay: json["statusDisplay"] ?? 'Inactive',
    );
}
