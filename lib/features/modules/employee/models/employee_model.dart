class Employee {
  final int id;
  final String cedula;
  final String nombre;
  final String departamento;
  final String estado;

  Employee({
    required this.id,
    required this.cedula,
    required this.nombre,
    required this.departamento,
    required this.estado,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      cedula: json['cedula'],
      nombre: json['nombre'],
      departamento: json['departamento'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cedula': cedula,
      'nombre': nombre,
      'departamento': departamento,
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'Empleado($id - $nombre)';
  }
}