class RequestArticles {
  final int id;
  final String empleadoSolicitante;
  final DateTime fechaSolicitud;
  final String articulo;
  final int cantidad;
  final String unidadMedida;
  final String estado;

  RequestArticles({
    required this.id,
    required this.empleadoSolicitante,
    required this.fechaSolicitud,
    required this.articulo,
    required this.cantidad,
    required this.unidadMedida,
    required this.estado,
  });

  factory RequestArticles.fromJson(Map<String, dynamic> json) {
    return RequestArticles(
      id: json['id'],
      empleadoSolicitante: json['empleadoSolicitante'],
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      articulo: json['articulo'],
      cantidad: json['cantidad'],
      unidadMedida: json['unidadMedida'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empleadoSolicitante': empleadoSolicitante,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'articulo': articulo,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida,
      'estado': estado,
    };
  }
}