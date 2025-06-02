import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/unit_model.dart';

class UnitService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Unit>> getAll() async {
    return await _client.getList<Unit>(
      '/unidades',
      (e) => Unit.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Unit> create(Unit unidad) async {
    return await _client.post<Unit>(
      '/unidades',
      unidad.toJson(),
      (e) => Unit.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/unidades/$id');
  }

  static Future<Unit> update(Unit unidad) async {
    return await _client.put<Unit>(
      '/unidades/${unidad.id}',
      unidad.toJson(),
      (e) => Unit.fromJson(e as Map<String, dynamic>),
    );
  }
}