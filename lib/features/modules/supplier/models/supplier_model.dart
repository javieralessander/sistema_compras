import 'dart:convert';

class Supplier {
  final int id;
  final String cedulaRnc;
  final String nombreComercial;
  final String estado;

  Supplier({
    required this.id,
    required this.cedulaRnc,
    required this.nombreComercial,
    required this.estado,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: int.parse(json['id'].toString()),
      cedulaRnc: json['cedulaRnc'],
      nombreComercial: json['nombreComercial'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cedulaRnc': cedulaRnc,
      'nombreComercial': nombreComercial,
      'estado': estado,
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
