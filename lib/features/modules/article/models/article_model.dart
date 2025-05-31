class Article {
  final int id;
  final String descripcion;
  final String marca;
  final String unidadMedida;
  final int existencia;
  final String estado;

  Article({
    required this.id,
    required this.descripcion,
    required this.marca,
    required this.unidadMedida,
    required this.existencia,
    required this.estado,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      descripcion: json['descripcion'],
      marca: json['marca'],
      unidadMedida: json['unidadMedida'],
      existencia: json['existencia'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'marca': marca,
      'unidadMedida': unidadMedida,
      'existencia': existencia,
      'estado': estado,
    };
  }
}