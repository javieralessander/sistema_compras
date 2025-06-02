import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/department_model.dart';

class DepartmentService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Department>> getAll() async {
    return await _client.getList<Department>(
      '/departamentos',
      (e) => Department.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Department> create(Department departamento) async {
    return await _client.post<Department>(
      '/departamentos',
      departamento.toJson(),
      (e) => Department.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/departamentos/$id');
  }

  static Future<Department> update(Department departamento) async {
    return await _client.put<Department>(
      '/departamentos/${departamento.id}',
      departamento.toJson(),
      (e) => Department.fromJson(e as Map<String, dynamic>),
    );
  }
}