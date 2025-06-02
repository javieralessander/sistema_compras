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
              r.items.any(
                (item) =>
                    item.articulo.descripcion.toLowerCase().contains(
                      _busqueda,
                    ) ||
                    item.unidadMedida.descripcion.toLowerCase().contains(
                      _busqueda,
                    ),
              ) ||
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

  Future<void> actualizarSolicitud(RequestArticles solicitud) async {
    try {
      final actualizado = await RequestService.update(solicitud);
      final index = _todos.indexWhere((r) => r.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar solicitud: $e');
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

  Future<void> aprobarSolicitud(int id) async {
    // Lógica para aprobar la solicitud (cambiar estado a 'Aprobado')
    // Actualiza la lista y notifica listeners
  }

  Future<void> anularSolicitud(int id) async {
    // Lógica para anular la solicitud (cambiar estado a 'Rechazado' o 'Anulado')
    // Actualiza la lista y notifica listeners
  }
}
