import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/unit_model.dart';

class UnitService {
  static const String baseUrl = 'https://tuapi.com/api/unidades';

  static final List<Unit> _pruebasData = [
    Unit(id: 1, descripcion: 'Kilogramo', estado: 'Activo'),
    Unit(id: 2, descripcion: 'Litro', estado: 'Activo'),
    Unit(id: 3, descripcion: 'Metro', estado: 'Activo'),
    Unit(id: 4, descripcion: 'Unidad', estado: 'Activo'),
    Unit(id: 5, descripcion: 'Caja', estado: 'Inactivo'),
  ];

  // Método para obtener unidades desde API real
  static Future<List<Unit>> getAllFromApi() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Unit.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener unidades');
    }
  }

  // Método para obtener unidades de prueba
  static Future<List<Unit>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _pruebasData;
  }

  static Future<Unit> create(Unit unidad) async {
    // Simulación en memoria
    final nuevo = Unit(
      id: _pruebasData.isEmpty ? 1 : _pruebasData.last.id + 1,
      descripcion: unidad.descripcion,
      estado: unidad.estado,
    );
    _pruebasData.add(nuevo);
    return nuevo;

    // Para API real:
    /*
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(unidad.toJson()),
    );
    if (response.statusCode == 201) {
      return Unit.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear unidad');
    }
    */
  }

  static Future<void> delete(int id) async {
    // Simulación en memoria
    _pruebasData.removeWhere((u) => u.id == id);

    // Para API real:
    /*
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar unidad');
    }
    */
  }

  static Future<Unit> update(Unit unidad) async {
    // Simulación en memoria
    final index = _pruebasData.indexWhere((u) => u.id == unidad.id);
    if (index != -1) {
      _pruebasData[index] = unidad;
      return unidad;
    } else {
      throw Exception('Unidad no encontrada');
    }

    // Para API real:
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/${unidad.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(unidad.toJson()),
    );
    if (response.statusCode == 200) {
      return Unit.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar unidad');
    }
    */
  }
}