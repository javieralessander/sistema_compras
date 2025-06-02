import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/request_articles_model.dart';

class RequestService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<RequestArticles>> getAll() async {
    return await _client.getList<RequestArticles>(
      '/solicitudes',
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<RequestArticles> create(RequestArticles solicitud) async {
    return await _client.post<RequestArticles>(
      '/solicitudes',
      solicitud.toJson(),
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
  }

  static Future<void> delete(int id) async {
    await _client.delete('/solicitudes/$id');
  }

  static Future<RequestArticles> update(RequestArticles solicitud) async {
    return await _client.put<RequestArticles>(
      '/solicitudes/${solicitud.id}',
      solicitud.toJson(),
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
  }
}