import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/employee_model.dart';

class EmployeeService {
  static const String baseUrl = 'https://tuapi.com/api/empleados';

  static final List<Employee> _pruebasData = [
    Employee(
      id: 1,
      cedula: '00112345678',
      nombre: 'Juan Pérez',
      departamento: 'Ventas',
      estado: 'Activo',
    ),
    Employee(
      id: 2,
      cedula: '00298765432',
      nombre: 'María Gómez',
      departamento: 'Recursos Humanos',
      estado: 'Inactivo',
    ),
    Employee(
      id: 3,
      cedula: '00345678901',
      nombre: 'Carlos Ruiz',
      departamento: 'Finanzas',
      estado: 'Activo',
    ),
    Employee(
      id: 4,
      cedula: '00411223344',
      nombre: 'Ana Torres',
      departamento: 'Marketing',
      estado: 'Activo',
    ),
    Employee(
      id: 5,
      cedula: '00555667788',
      nombre: 'Luis Fernández',
      departamento: 'IT',
      estado: 'Inactivo',
    ),
    Employee(
      id: 6,
      cedula: '00699887766',
      nombre: 'Sofía Martínez',
      departamento: 'Atención al Cliente',
      estado: 'Activo',
    ),
    Employee(
      id: 7,
      cedula: '00712341234',
      nombre: 'José Ramírez',
      departamento: 'Compras',
      estado: 'Activo',
    ),
    Employee(
      id: 8,
      cedula: '00843211234',
      nombre: 'Laura Castro',
      departamento: 'Legal',
      estado: 'Inactivo',
    ),
    Employee(
      id: 9,
      cedula: '00911122233',
      nombre: 'Miguel Peña',
      departamento: 'Calidad',
      estado: 'Activo',
    ),
    Employee(
      id: 10,
      cedula: '01044455566',
      nombre: 'Elena Bautista',
      departamento: 'Administración',
      estado: 'Activo',
    ),
  ];

  static Future<List<Employee>> getAll1() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Employee.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener empleados');
    }
  }
  // Método para obtener empleados de prueba
 static Future<List<Employee>> getAll() async {
    // Simula una llamada a la API devolviendo los datos de prueba
    await Future.delayed(Duration(milliseconds: 300));
    return _pruebasData;
  }



  static Future<Employee> create(Employee empleado) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(empleado.toJson()),
    );

    if (response.statusCode == 201) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear empleado');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar empleado');
    }
  }

  static Future<Employee> update(Employee empleado) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${empleado.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(empleado.toJson()),
    );

    if (response.statusCode == 200) {
      return Employee.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar empleado');
    }
  }
}
