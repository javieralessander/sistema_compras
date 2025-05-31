class Unit {
  final int id;
  final String descripcion;
  final String estado;

  Unit({
    required this.id,
    required this.descripcion,
    required this.estado,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'],
      descripcion: json['descripcion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  @override
  String toString() => 'Unidad($id - $descripcion)';
}