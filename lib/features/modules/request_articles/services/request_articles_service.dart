import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/request_articles_model.dart';
class RequestService {
  static const String baseUrl = 'https://tuapi.com/api/solicitudes';

  static final List<RequestArticles> _pruebasData = [
    RequestArticles(
      id: 1,
      empleadoSolicitante: 'Juan Pérez',
      fechaSolicitud: DateTime(2024, 6, 1),
      articulo: 'Laptop 15"',
      cantidad: 2,
      unidadMedida: 'Unidad',
      estado: 'Pendiente',
    ),
    RequestArticles(
      id: 2,
      empleadoSolicitante: 'María Gómez',
      fechaSolicitud: DateTime(2024, 6, 2),
      articulo: 'Papel A4',
      cantidad: 10,
      unidadMedida: 'Caja',
      estado: 'Aprobado',
    ),
    RequestArticles(
      id: 3,
      empleadoSolicitante: 'Carlos Ruiz',
      fechaSolicitud: DateTime(2024, 6, 3),
      articulo: 'Tóner',
      cantidad: 1,
      unidadMedida: 'Caja',
      estado: 'Rechazado',
    ),
  ];

  // Método para obtener solicitudes desde API real
  static Future<List<RequestArticles>> getAllFromApi() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RequestArticles.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener solicitudes');
    }
  }

  // Método para obtener solicitudes de prueba
  static Future<List<RequestArticles>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _pruebasData;
  }

  static Future<RequestArticles> create(RequestArticles solicitud) async {
    // Simulación en memoria
    final nuevo = RequestArticles(
      id: _pruebasData.isEmpty ? 1 : _pruebasData.last.id + 1,
      empleadoSolicitante: solicitud.empleadoSolicitante,
      fechaSolicitud: solicitud.fechaSolicitud,
      articulo: solicitud.articulo,
      cantidad: solicitud.cantidad,
      unidadMedida: solicitud.unidadMedida,
      estado: solicitud.estado,
    );
    _pruebasData.add(nuevo);
    return nuevo;

    // Para API real:
    /*
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(solicitud.toJson()),
    );
    if (response.statusCode == 201) {
      return Request.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear solicitud');
    }
    */
  }

  static Future<void> delete(int id) async {
    // Simulación en memoria
    _pruebasData.removeWhere((r) => r.id == id);

    // Para API real:
    /*
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar solicitud');
    }
    */
  }

  static Future<RequestArticles> update(RequestArticles solicitud) async {
    // Simulación en memoria
    final index = _pruebasData.indexWhere((r) => r.id == solicitud.id);
    if (index != -1) {
      _pruebasData[index] = solicitud;
      return solicitud;
    } else {
      throw Exception('Solicitud no encontrada');
    }

    // Para API real:
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/${solicitud.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(solicitud.toJson()),
    );
    if (response.statusCode == 200) {
      return Request.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar solicitud');
    }
    */
  }
}