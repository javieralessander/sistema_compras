import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/department_model.dart';

class DepartmentService {
  static const String baseUrl = 'https://tuapi.com/api/departamentos';

  static final List<Department> _pruebasData = [
    Department(id: 1, nombre: 'Ventas', estado: 'Activo'),
    Department(id: 2, nombre: 'Recursos Humanos', estado: 'Activo'),
    Department(id: 3, nombre: 'Finanzas', estado: 'Inactivo'),
    Department(id: 4, nombre: 'IT', estado: 'Activo'),
    Department(id: 5, nombre: 'Marketing', estado: 'Activo'),
    Department(id: 6, nombre: 'Logística', estado: 'Inactivo'),
    Department(id: 7, nombre: 'Atención al Cliente', estado: 'Activo'),
    Department(id: 8, nombre: 'Producción', estado: 'Activo'),
    Department(id: 9, nombre: 'Calidad', estado: 'Activo'),
    Department(id: 10, nombre: 'Investigación y Desarrollo', estado: 'Activo'),
    Department(id: 11, nombre: 'Compras', estado: 'Activo'),
  ];

  // Llama a la API real
  static Future<List<Department>> getAll1() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Department.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener departamentos');
    }
  }

  // Devuelve datos de prueba
  static Future<List<Department>> getAll() async {
    await Future.delayed(Duration(milliseconds: 300));
    return _pruebasData;
  }

  static Future<Department> create(Department departamento) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(departamento.toJson()),
    );

    if (response.statusCode == 201) {
      return Department.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear departamento');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar departamento');
    }
  }

  static Future<Department> update(Department departamento) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${departamento.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(departamento.toJson()),
    );

    if (response.statusCode == 200) {
      return Department.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar departamento');
    }
  }
}