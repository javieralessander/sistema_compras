import 'package:flutter/material.dart';
import '../models/department_model.dart';
import '../services/department_service.dart';

class DepartmentProvider extends ChangeNotifier {
  List<Department> _todos = [];
  List<Department> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 5;

  String _busqueda = '';

  List<Department> get departamentos => _pagina;
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Department> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (d) =>
              d.nombre.toLowerCase().contains(_busqueda) ||
              d.estado.toLowerCase().contains(_busqueda),
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

  Future<void> cargarDepartamentos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DepartmentService.getAll();
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar departamentos: $e');
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

  Future<void> agregarDepartamento(Department departamento) async {
    try {
      final nuevo = await DepartmentService.create(departamento);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar departamento: $e');
    }
  }

  Future<void> eliminarDepartamento(int id) async {
    try {
      await DepartmentService.delete(id);
      _todos.removeWhere((d) => d.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar departamento: $e');
    }
  }
}