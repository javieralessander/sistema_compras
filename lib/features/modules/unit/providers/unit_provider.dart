import 'package:flutter/material.dart';
import '../models/unit_model.dart';
import '../services/unit_service.dart';

class UnitProvider extends ChangeNotifier {
  List<Unit> _todos = [];
  List<Unit> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 5;

  String _busqueda = '';

  List<Unit> get unidades => _pagina;
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Unit> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (u) =>
              u.descripcion.toLowerCase().contains(_busqueda) ||
              u.estado.toLowerCase().contains(_busqueda),
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

  Future<void> cargarUnidades() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await UnitService.getAll();
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar unidades: $e');
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

  Future<void> agregarUnidad(Unit unidad) async {
    try {
      final nuevo = await UnitService.create(unidad);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar unidad: $e');
    }
  }

  Future<void> eliminarUnidad(int id) async {
    try {
      await UnitService.delete(id);
      _todos.removeWhere((u) => u.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar unidad: $e');
    }
  }
}