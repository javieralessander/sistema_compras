class Department {
  final int id;
  final String nombre;
  final String estado;

  Department({
    required this.id,
    required this.nombre,
    required this.estado,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      nombre: json['nombre'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'Departamento($id - $nombre)';
  }
}