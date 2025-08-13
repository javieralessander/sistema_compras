import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../modules/article/models/article_model.dart';
class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Article>> fetchArticulos() async {
    final response = await http.get(Uri.parse('$baseUrl/articulos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Article.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar artículos');
    }
  }
}