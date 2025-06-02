import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/purchase_order_model.dart';

class PurchaseOrderService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<PurchaseOrder>> getAll() async {
    return await _client.getList<PurchaseOrder>(
      '/ordenesCompra',
      (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<PurchaseOrder> create(PurchaseOrder orden) async {
    return await _client.post<PurchaseOrder>(
      '/ordenesCompra',
      orden.toJson(),
      (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int numeroOrden) async {
    await _client.delete('/ordenesCompra/$numeroOrden');
  }

  static Future<PurchaseOrder> update(PurchaseOrder orden) async {
    return await _client.put<PurchaseOrder>(
      '/ordenesCompra/${orden.numeroOrden}',
      orden.toJson(),
      (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
    );
  }
}