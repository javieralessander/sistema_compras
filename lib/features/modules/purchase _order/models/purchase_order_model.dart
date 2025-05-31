class PurchaseOrder {
  final int numeroOrden;
  final int idSolicitud;
  final DateTime fechaOrden;
  final String estado;
  final String articulo;
  final int cantidad;
  final String unidadMedida;
  final String marca;
  final double costoUnitario;

  PurchaseOrder({
    required this.numeroOrden,
    required this.idSolicitud,
    required this.fechaOrden,
    required this.estado,
    required this.articulo,
    required this.cantidad,
    required this.unidadMedida,
    required this.marca,
    required this.costoUnitario,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      numeroOrden: json['numeroOrden'],
      idSolicitud: json['idSolicitud'],
      fechaOrden: DateTime.parse(json['fechaOrden']),
      estado: json['estado'],
      articulo: json['articulo'],
      cantidad: json['cantidad'],
      unidadMedida: json['unidadMedida'],
      marca: json['marca'],
      costoUnitario: (json['costoUnitario'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroOrden': numeroOrden,
      'idSolicitud': idSolicitud,
      'fechaOrden': fechaOrden.toIso8601String(),
      'estado': estado,
      'articulo': articulo,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida,
      'marca': marca,
      'costoUnitario': costoUnitario,
    };
  }
}