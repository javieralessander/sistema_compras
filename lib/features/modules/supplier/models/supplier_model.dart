import 'dart:convert';

class Supplier {
  final int id;
  final String cedulaRnc;
  final String nombreComercial;
  final bool isActive;

  Supplier({
    required this.id,
    required this.cedulaRnc,
    required this.nombreComercial,
    this.isActive = true,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: int.parse(json['id'].toString()),
      cedulaRnc: json['cedulaRnc'],
      nombreComercial: json['nombreComercial'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedulaRnc': cedulaRnc,
      'nombreComercial': nombreComercial,
      'isActive': isActive,
    };
  }

  // Métodos para trabajar con JSON crudo
  factory Supplier.fromRawJson(String str) =>
      Supplier.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Supplier && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
