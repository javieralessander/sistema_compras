import 'dart:convert';

class Unit {
  final int id;
  final String descripcion;
  final String estado;

  Unit({required this.id, required this.descripcion, required this.estado});

  // Instancias estáticas para pruebas

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'descripcion': descripcion, 'estado': estado};
  }

  // Métodos para trabajar con JSON crudo
  factory Unit.fromRawJson(String str) => Unit.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() => 'Unidad($id - $descripcion)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
