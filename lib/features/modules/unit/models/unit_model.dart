import 'dart:convert';

class Unit {
  final int id;
  final String descripcion;
  final bool isActive;

  Unit({required this.id, required this.descripcion, this.isActive = true});

  // Instancias estáticas para pruebas

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'descripcion': descripcion, 'isActive': isActive};
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
