import 'package:flutter/material.dart';
import '../models/purchase_order_model.dart';
import '../services/purchase _order_service.dart';

class PurchaseOrderProvider extends ChangeNotifier {
  List<PurchaseOrder> _todos = [];
  List<PurchaseOrder> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 5;

  String _busqueda = '';

  List<PurchaseOrder> get ordenes => _pagina;
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<PurchaseOrder> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (o) =>
              o.numeroOrden.toString().contains(_busqueda) ||
              o.idSolicitud.toString().contains(_busqueda) ||
              o.estado.toLowerCase().contains(_busqueda) ||
              o.articulo.toLowerCase().contains(_busqueda) ||
              o.unidadMedida.toLowerCase().contains(_busqueda) ||
              o.marca.toLowerCase().contains(_busqueda),
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

  Future<void> cargarOrdenes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await PurchaseOrderService.getAll();
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar órdenes: $e');
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

  Future<void> agregarOrden(PurchaseOrder orden) async {
    try {
      final nuevo = await PurchaseOrderService.create(orden);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar orden: $e');
    }
  }

  Future<void> eliminarOrden(int numeroOrden) async {
    try {
      await PurchaseOrderService.delete(numeroOrden);
      _todos.removeWhere((o) => o.numeroOrden == numeroOrden);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar orden: $e');
    }
  }
}