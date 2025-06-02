import 'dart:convert';

class Brand {
  final int id;
  final String descripcion;
  final String estado;

  Brand({required this.id, required this.descripcion, required this.estado});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descripcion': descripcion, 'estado': estado};
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
