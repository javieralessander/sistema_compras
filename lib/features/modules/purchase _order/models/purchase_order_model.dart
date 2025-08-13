import 'dart:convert';

class PurchaseOrder {
  // Constantes para los estados de la orden de compra
  static const String ESTADO_GENERADA = 'generada';
  static const String ESTADO_PROCESADA = 'procesada';
  static const String ESTADO_COMPLETADA = 'completada';
  static const String ESTADO_CANCELADA = 'cancelada';

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
    try {
      return PurchaseOrder(
        numeroOrden: _parseIntSafe(json['numeroOrden']),
        idSolicitud: _parseIntSafe(json['idSolicitud']),
        fechaOrden: _parseDateTimeSafe(json['fechaOrden']),
        estado: json['estado']?.toString() ?? '',
        items: _parseItemsSafe(json['items']),
      );
    } catch (e) {
      print('ERROR parseando PurchaseOrder: $e');
      print('JSON recibido: $json');
      rethrow;
    }
  }

  // Métodos helper para parsing seguro
  static int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDateTimeSafe(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('ERROR parseando fecha: $value');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static List<PurchaseOrderItem> _parseItemsSafe(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];
    
    return value
        .map((e) {
          try {
            return PurchaseOrderItem.fromJson(e as Map<String, dynamic>);
          } catch (error) {
            print('ERROR parseando item: $error');
            print('Item JSON: $e');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<PurchaseOrderItem>()
        .toList();
  }

  static int? _parseIntSafeNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double _parseDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'idSolicitud': idSolicitud,
      'fechaOrden': fechaOrden.toIso8601String(),
      'estado': estado,
      'items': items.map((e) => e.toJson()).toList(),
      // No enviar numeroOrden en CREATE, se genera en el backend
    };
  }

  /// JSON específico para CREATE (sin numeroOrden)
  Map<String, dynamic> toJsonForCreate() {
    return {
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
  final int? id; // ID del item para poder actualizarlo
  final String articulo;
  final int cantidad;
  final String unidadMedida;
  final String marca;
  final double costoUnitario;

  PurchaseOrderItem({
    this.id, // Opcional porque en CREATE no se envía
    required this.articulo,
    required this.cantidad,
    required this.unidadMedida,
    required this.marca,
    required this.costoUnitario,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    print('=== DEBUG: Parseando PurchaseOrderItem ===');
    print('JSON completo: $json');
    print('Cantidad cruda: ${json['cantidad']} (tipo: ${json['cantidad'].runtimeType})');
    
    try {
      final cantidadParsed = PurchaseOrder._parseIntSafe(json['cantidad']);
      print('Cantidad parseada: $cantidadParsed');
      
      // ALERTA: Si cantidad viene como null desde el backend, algo está mal
      if (json['cantidad'] == null) {
        print('⚠️ ALERTA: Cantidad es null en el JSON del backend');
        print('⚠️ Esto indica un problema en el backend o en el proceso de creación');
        print('⚠️ Verificar el endpoint createOrdenItem y la tabla de BD');
      }
      
      return PurchaseOrderItem(
        id: PurchaseOrder._parseIntSafeNullable(json['id']),
        articulo: json['articulo']?.toString() ?? '',
        cantidad: cantidadParsed,
        unidadMedida: json['unidadMedida']?.toString() ?? '',
        marca: json['marca']?.toString() ?? '',
        costoUnitario: PurchaseOrder._parseDoubleSafe(json['costoUnitario']),
      );
    } catch (e) {
      print('ERROR parseando PurchaseOrderItem: $e');
      print('JSON recibido: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id, // Solo incluir si existe
      'articulo': articulo,
      'cantidad': cantidad,
      'unidadMedida': unidadMedida,
      'marca': marca,
      'costoUnitario': costoUnitario,
    };
  }
}