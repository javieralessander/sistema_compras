import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/purchase_order_model.dart';

class PurchaseOrderService {
  static const String baseUrl = 'https://tuapi.com/api/ordenes';

  static final List<PurchaseOrder> _pruebasData = [
    PurchaseOrder(
      numeroOrden: 1,
      idSolicitud: 101,
      fechaOrden: DateTime(2024, 6, 1),
      estado: 'Pendiente',
      articulo: 'Laptop 15"',
      cantidad: 2,
      unidadMedida: 'Unidad',
      marca: 'HP',
      costoUnitario: 1200.0,
    ),
    PurchaseOrder(
      numeroOrden: 2,
      idSolicitud: 102,
      fechaOrden: DateTime(2024, 6, 2),
      estado: 'Aprobada',
      articulo: 'Monitor 24"',
      cantidad: 5,
      unidadMedida: 'Unidad',
      marca: 'Samsung',
      costoUnitario: 350.0,
    ),
  ];

  // Método para obtener órdenes desde API real
  static Future<List<PurchaseOrder>> getAllFromApi() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => PurchaseOrder.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener órdenes');
    }
  }

  // Método para obtener órdenes de prueba
  static Future<List<PurchaseOrder>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _pruebasData;
  }

  static Future<PurchaseOrder> create(PurchaseOrder orden) async {
    // Simulación en memoria
    final nuevo = PurchaseOrder(
      numeroOrden: _pruebasData.isEmpty ? 1 : _pruebasData.last.numeroOrden + 1,
      idSolicitud: orden.idSolicitud,
      fechaOrden: orden.fechaOrden,
      estado: orden.estado,
      articulo: orden.articulo,
      cantidad: orden.cantidad,
      unidadMedida: orden.unidadMedida,
      marca: orden.marca,
      costoUnitario: orden.costoUnitario,
    );
    _pruebasData.add(nuevo);
    return nuevo;

    // Para API real:
    /*
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orden.toJson()),
    );
    if (response.statusCode == 201) {
      return PurchaseOrder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear orden');
    }
    */
  }

  static Future<void> delete(int numeroOrden) async {
    // Simulación en memoria
    _pruebasData.removeWhere((o) => o.numeroOrden == numeroOrden);

    // Para API real:
    /*
    final response = await http.delete(Uri.parse('$baseUrl/$numeroOrden'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar orden');
    }
    */
  }

  static Future<PurchaseOrder> update(PurchaseOrder orden) async {
    // Simulación en memoria
    final index = _pruebasData.indexWhere((o) => o.numeroOrden == orden.numeroOrden);
    if (index != -1) {
      _pruebasData[index] = orden;
      return orden;
    } else {
      throw Exception('Orden no encontrada');
    }

    // Para API real:
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/${orden.numeroOrden}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(orden.toJson()),
    );
    if (response.statusCode == 200) {
      return PurchaseOrder.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar orden');
    }
    */
  }
}