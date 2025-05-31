class Brand {
  final int id;
  final String descripcion;
  final String estado;

  Brand({
    required this.id,
    required this.descripcion,
    required this.estado,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
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
  String toString() => 'Marca($id - $descripcion)';
}