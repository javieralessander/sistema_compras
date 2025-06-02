import 'package:flutter/material.dart';
import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _todos = [];
  List<Supplier> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 5;

  String _busqueda = '';

  List<Supplier> get proveedores => _pagina;
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Supplier> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (p) =>
              p.cedulaRnc.toLowerCase().contains(_busqueda) ||
              p.nombreComercial.toLowerCase().contains(_busqueda) ||
              p.estado.toLowerCase().contains(_busqueda),
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

  Future<void> cargarProveedores() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupplierService.getAll();
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar proveedores: $e');
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

  Future<void> agregarProveedor(Supplier proveedor) async {
    try {
      final nuevo = await SupplierService.create(proveedor);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar proveedor: $e');
    }
  }

  Future<void> actualizarProveedor(Supplier proveedor) async {
    try {
      final actualizado = await SupplierService.update(proveedor);
      final index = _todos.indexWhere((p) => p.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar proveedor: $e');
    }
  }

  Future<void> eliminarProveedor(int id) async {
    try {
      await SupplierService.delete(id);
      _todos.removeWhere((p) => p.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar proveedor: $e');
    }
  }
}
