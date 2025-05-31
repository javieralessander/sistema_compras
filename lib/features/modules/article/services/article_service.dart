import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ArticleService {
  static const String baseUrl = 'https://tuapi.com/api/articulos';

  static final List<Article> _pruebasData = [
    Article(id: 1, descripcion: 'Laptop 15"', marca: 'HP', unidadMedida: 'Unidad', existencia: 10, estado: 'Activo'),
    Article(id: 2, descripcion: 'Monitor 24"', marca: 'Samsung', unidadMedida: 'Unidad', existencia: 5, estado: 'Activo'),
    Article(id: 3, descripcion: 'Tóner', marca: 'Canon', unidadMedida: 'Caja', existencia: 20, estado: 'Inactivo'),
    Article(id: 4, descripcion: 'Silla ergonómica', marca: 'Ergo', unidadMedida: 'Unidad', existencia: 7, estado: 'Activo'),
    Article(id: 5, descripcion: 'Papel A4', marca: 'Chamex', unidadMedida: 'Caja', existencia: 50, estado: 'Activo'),
  ];

  // Método para obtener artículos desde API real
  static Future<List<Article>> getAllFromApi() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Article.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener artículos');
    }
  }

  // Método para obtener artículos de prueba
  static Future<List<Article>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _pruebasData;
  }

  static Future<Article> create(Article articulo) async {
    // Simulación en memoria
    final nuevo = Article(
      id: _pruebasData.isEmpty ? 1 : _pruebasData.last.id + 1,
      descripcion: articulo.descripcion,
      marca: articulo.marca,
      unidadMedida: articulo.unidadMedida,
      existencia: articulo.existencia,
      estado: articulo.estado,
    );
    _pruebasData.add(nuevo);
    return nuevo;

    // Para API real:
    /*
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(articulo.toJson()),
    );
    if (response.statusCode == 201) {
      return Article.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear artículo');
    }
    */
  }

  static Future<void> delete(int id) async {
    // Simulación en memoria
    _pruebasData.removeWhere((a) => a.id == id);

    // Para API real:
    /*
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar artículo');
    }
    */
  }

  static Future<Article> update(Article articulo) async {
    // Simulación en memoria
    final index = _pruebasData.indexWhere((a) => a.id == articulo.id);
    if (index != -1) {
      _pruebasData[index] = articulo;
      return articulo;
    } else {
      throw Exception('Artículo no encontrado');
    }

    // Para API real:
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/${articulo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(articulo.toJson()),
    );
    if (response.statusCode == 200) {
      return Article.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar artículo');
    }
    */
  }
}