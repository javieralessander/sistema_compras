import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/brand_model.dart';

class BrandService {
  static const String baseUrl = 'https://tuapi.com/api/marcas';

  static final List<Brand> _pruebasData = [
    Brand(id: 1, descripcion: 'Sony', estado: 'Activo'),
    Brand(id: 2, descripcion: 'Samsung', estado: 'Activo'),
    Brand(id: 3, descripcion: 'LG', estado: 'Inactivo'),
    Brand(id: 4, descripcion: 'HP', estado: 'Activo'),
    Brand(id: 5, descripcion: 'Lenovo', estado: 'Activo'),
  ];

  // Método para obtener marcas desde API real
  static Future<List<Brand>> getAllFromApi() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Brand.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener marcas');
    }
  }

  // Método para obtener marcas de prueba
  static Future<List<Brand>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _pruebasData;
  }

  static Future<Brand> create(Brand marca) async {
    // Simulación en memoria
    final nuevo = Brand(
      id: _pruebasData.isEmpty ? 1 : _pruebasData.last.id + 1,
      descripcion: marca.descripcion,
      estado: marca.estado,
    );
    _pruebasData.add(nuevo);
    return nuevo;

    // Para API real:
    /*
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(marca.toJson()),
    );
    if (response.statusCode == 201) {
      return Brand.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear marca');
    }
    */
  }

  static Future<void> delete(int id) async {
    // Simulación en memoria
    _pruebasData.removeWhere((m) => m.id == id);

    // Para API real:
    /*
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar marca');
    }
    */
  }

  static Future<Brand> update(Brand marca) async {
    // Simulación en memoria
    final index = _pruebasData.indexWhere((m) => m.id == marca.id);
    if (index != -1) {
      _pruebasData[index] = marca;
      return marca;
    } else {
      throw Exception('Marca no encontrada');
    }

    // Para API real:
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/${marca.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(marca.toJson()),
    );
    if (response.statusCode == 200) {
      return Brand.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar marca');
    }
    */
  }
}