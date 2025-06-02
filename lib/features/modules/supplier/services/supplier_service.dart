import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/supplier_model.dart';

class SupplierService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Supplier>> getAll() async {
    return await _client.getList<Supplier>(
      '/proveedores',
      (e) => Supplier.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Supplier> create(Supplier proveedor) async {
    return await _client.post<Supplier>(
      '/proveedores',
      proveedor.toJson(),
      (e) => Supplier.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/proveedores/$id');
  }

  static Future<Supplier> update(Supplier proveedor) async {
    return await _client.put<Supplier>(
      '/proveedores/${proveedor.id}',
      proveedor.toJson(),
      (e) => Supplier.fromJson(e as Map<String, dynamic>),
    );
  }
}