import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/article_model.dart';

class ArticleService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<Article>> getAll() async {
    return await _client.getList<Article>(
      '/articulos',
      (e) => Article.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<Article> create(Article articulo) async {
    return await _client.post<Article>(
      '/articulos',
      articulo.toJson(),
      (e) => Article.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/articulos/$id');
  }

  static Future<Article> update(Article articulo) async {
    return await _client.put<Article>(
      '/articulos/${articulo.id}',
      articulo.toJson(),
      (e) => Article.fromJson(e as Map<String, dynamic>),
    );
  }
}