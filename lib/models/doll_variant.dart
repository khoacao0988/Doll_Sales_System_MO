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

DollVariant dollVariantFromJson(String str) {
    final jsonData = json.decode(str);
    // Handle cases where the doll data is nested under a "data" key
    if (jsonData.containsKey('data') && jsonData['data'] is Map) {
        return DollVariant.fromJson(jsonData['data']);
    }
    return DollVariant.fromJson(jsonData);
}

class DollVariant {
    final int dollVariantId;
    final int dollModelId;
    final String dollModelName;
    final String name;
    final num price;
    final String? color;
    final String? size;
    final String? image;
    final bool? isActive;

    DollVariant({
        required this.dollVariantId,
        required this.dollModelId,
        required this.dollModelName,
        required this.name,
        required this.price,
        this.color,
        this.size,
        this.image,
        this.isActive,
    });

    factory DollVariant.fromJson(Map<String, dynamic> json) => DollVariant(
        dollVariantId: _parseDynamicInt(json["dollVariantID"]),
        dollModelId: _parseDynamicInt(json["dollModelID"]),
        dollModelName: json["dollModelName"],
        name: json["name"],
        price: json["price"] is String ? (num.tryParse(json["price"]) ?? 0) : json["price"], // Also make price robust
        color: json["color"],
        size: json["size"],
        image: json["image"],
        isActive: json["isActive"],
    );
}
