import 'dart:convert';

class Department {
  final int id;
  final String nombre;
  final String estado;

  Department({required this.id, required this.nombre, required this.estado});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nombre': nombre, 'estado': estado};
  }

  // Métodos para trabajar con JSON crudo
  factory Department.fromRawJson(String str) =>
      Department.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() {
    return 'Departamento($id - $nombre)';
  }

  Department copyWith({int? id, String? nombre, String? estado}) {
    return Department(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      estado: estado ?? this.estado,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
