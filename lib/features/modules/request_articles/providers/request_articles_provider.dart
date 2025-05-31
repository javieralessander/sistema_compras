import 'package:flutter/material.dart';

import '../models/request_articles_model.dart';
import '../services/request_articles_service.dart';

class RequestProvider extends ChangeNotifier {
  List<RequestArticles> _todos = [];
  List<RequestArticles> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 5;

  String _busqueda = '';

  List<RequestArticles> get solicitudes => _pagina;
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<RequestArticles> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (r) =>
              r.empleadoSolicitante.toLowerCase().contains(_busqueda) ||
              r.articulo.toLowerCase().contains(_busqueda) ||
              r.unidadMedida.toLowerCase().contains(_busqueda) ||
              r.estado.toLowerCase().contains(_busqueda),
        )
        .toList();
  }

  int get totalRegistros => _filtrados.length;
  int get totalPaginas => (totalRegistros / _registrosPorPagina).ceil();
  int get inicio => (_paginaActual - 1) * _registrosPorPagina;
  int get fin => (_paginaActual * _registrosPorPagina).clamp(0, totalRegistros);

  set busqueda(String value) {
    _busqueda = value.toLowerCase();
    _paginaActual = 1;
    _actualizarPagina();
  }

  Future<void> cargarSolicitudes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await RequestService.getAll();
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar solicitudes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _actualizarPagina() {
    final filtrados = _filtrados;
    if (filtrados.isEmpty) {
      if (_pagina.isNotEmpty || _paginaActual != 1) {
        _paginaActual = 1;
        _pagina = [];
        notifyListeners();
      }
      return;
    }
    if (_paginaActual > totalPaginas) {
      _paginaActual = 1;
    }
    final start = inicio;
    final end = fin > filtrados.length ? filtrados.length : fin;
    _pagina = filtrados.sublist(start, end);
    notifyListeners();
  }

  void cambiarPagina(int nuevaPagina) {
    if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas) {
      _paginaActual = nuevaPagina;
      _actualizarPagina();
    }
  }

  void cambiarRegistrosPorPagina(int cantidad) {
    _registrosPorPagina = cantidad;
    _paginaActual = 1;
    _actualizarPagina();
  }

  Future<void> agregarSolicitud(RequestArticles solicitud) async {
    try {
      final nuevo = await RequestService.create(solicitud);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar solicitud: $e');
    }
  }

  Future<void> eliminarSolicitud(int id) async {
    try {
      await RequestService.delete(id);
      _todos.removeWhere((r) => r.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar solicitud: $e');
    }
  }
}