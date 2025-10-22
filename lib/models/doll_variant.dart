import 'dart:convert';

DollVariant dollVariantFromJson(String str) => DollVariant.fromJson(json.decode(str));

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
        dollVariantId: json["dollVariantID"],
        dollModelId: json["dollModelID"],
        dollModelName: json["dollModelName"],
        name: json["name"],
        price: json["price"],
        color: json["color"],
        size: json["size"],
        image: json["image"],
        isActive: json["isActive"],
    );
}
