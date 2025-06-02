import 'dart:convert';

class PurchaseOrder {
  final int numeroOrden;
  final int idSolicitud;
  final DateTime fechaOrden;
  final String estado;
  final List<PurchaseOrderItem> items;

  PurchaseOrder({
    required this.numeroOrden,
    required this.idSolicitud,
    required this.fechaOrden,
    required this.estado,
    required this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      numeroOrden: json['numeroOrden'],
      idSolicitud: json['idSolicitud'],
      fechaOrden: DateTime.parse(json['fechaOrden']),
      estado: json['estado'],
      items: (json['items'] as List)
          .map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroOrden': numeroOrden,
      'idSolicitud': idSolicitud,
      'fechaOrden': fechaOrden.toIso8601String(),
      'estado': estado,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory PurchaseOrder.fromRawJson(String str) => PurchaseOrder.fromJson(json.decode(str));
  String toRawJson() => json.encode(toJson());
}

class PurchaseOrderItem {
  final String articulo;
  final int cantidad;
  final String unidadMedida;
  final String marca;
  final double costoUnitario;

  PurchaseOrderItem({
    required this.articulo,
    required this.cantidad,
    required this.unidadMedida,
    required this.marca,
    required this.costoUnitario,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      articulo: json['articulo'],
      cantidad: json['cantidad'],
      unidadMedida: json['unidadMedida'],
      marca: json['marca'],
      costoUnitario: (json['costoUnitario'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'articulo': articulo,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida,
      'marca': marca,
      'costoUnitario': costoUnitario,
    };
  }
}