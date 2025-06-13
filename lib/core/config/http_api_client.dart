import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpApiClient {
  final String baseUrl;

  HttpApiClient(this.baseUrl);

  Future<T> get<T>(String endpoint, T Function(dynamic) fromJson) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    final data = _processResponse(response);
    return fromJson(data);
  }

  Future<List<T>> getList<T>(String endpoint, T Function(dynamic) fromJson) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    final data = _processResponse(response);
    return (data as List).map((e) => fromJson(e)).toList();
  }

  Future<T> post<T>(String endpoint, dynamic body, T Function(dynamic) fromJson) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = _processResponse(response);
    return fromJson(data);
  }

  Future<T> put<T>(String endpoint, dynamic body, T Function(dynamic) fromJson) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = _processResponse(response);
    return fromJson(data);
  }

  Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar recurso');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }
}