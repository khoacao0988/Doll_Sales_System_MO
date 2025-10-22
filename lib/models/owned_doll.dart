import 'dart:convert';

// A function to parse the list of owned dolls from the API response
List<OwnedDoll> ownedDollFromJson(String str) {
  final Map<String, dynamic> jsonData = json.decode(str);
  final List<dynamic> dollList = jsonData['data'] ?? [];
  return List<OwnedDoll>.from(dollList.map((x) => OwnedDoll.fromJson(x)));
}

class OwnedDoll {
    final int ownedDollId;
    final int userId;
    final int dollVariantId;
    final String dollVariantName;

    OwnedDoll({
        required this.ownedDollId,
        required this.userId,
        required this.dollVariantId,
        required this.dollVariantName,
    });

    factory OwnedDoll.fromJson(Map<String, dynamic> json) => OwnedDoll(
        ownedDollId: json["ownedDollID"],
        userId: json["userID"],
        dollVariantId: json["dollVariantID"],
        dollVariantName: json["dollVariantName"],
    );
}
