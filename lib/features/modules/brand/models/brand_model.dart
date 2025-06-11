import 'dart:convert';

class Brand {
  final int id;
  final String descripcion;
  final bool isActive;

  Brand({required this.id, required this.descripcion, this.isActive = true});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descripcion': descripcion, 'isActive': isActive};
  }

  // Métodos para trabajar con JSON crudo
  factory Brand.fromRawJson(String str) => Brand.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'Marca($id - $descripcion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Brand && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
