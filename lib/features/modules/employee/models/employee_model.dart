import 'dart:convert';
import '../../department/models/department_model.dart';

class Employee {
  final int id;
  final String cedula;
  final String nombre;
  final Department departamento; // Relación uno a uno
  final bool isActive;

  Employee({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.departamento,
    this.isActive = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: int.parse(json['id'].toString()),
      cedula: json['cedula'],
      nombre: json['nombre'],
      departamento: Department.fromJson(json['departamento']),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cedula': cedula,
      'nombre': nombre,
      'departamentoId': departamento.id,
      'isActive': isActive,
    };
  }

  // Métodos para trabajar con JSON crudo
  factory Employee.fromRawJson(String str) =>
      Employee.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() {
    return 'Empleado($id - $nombre)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
