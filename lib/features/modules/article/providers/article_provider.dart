import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/article_service.dart';

class ArticleProvider extends ChangeNotifier {
  ArticleProvider() {
    cargarArticulos();
  }
  List<Article> _todos = [];
  List<Article> _pagina = [];

  bool _isLoading = false;
  int _paginaActual = 1;
  int _registrosPorPagina = 5;

  String _busqueda = '';

  List<Article> get articulos => _pagina;
  bool get isLoading => _isLoading;
  int get paginaActual => _paginaActual;
  int get registrosPorPagina => _registrosPorPagina;

  List<Article> get _filtrados {
    if (_busqueda.isEmpty) return _todos;
    return _todos
        .where(
          (a) =>
              a.descripcion.toLowerCase().contains(_busqueda) ||
              a.marca.descripcion.toLowerCase().contains(_busqueda) ||
              a.unidadMedida.descripcion.toLowerCase().contains(_busqueda) ||
              a.estado.toLowerCase().contains(_busqueda),
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

  Future<void> cargarArticulos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ArticleService.getAll();
      _todos = data;
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar artículos: $e');
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

  Future<void> agregarArticulo(Article articulo) async {
    try {
      final nuevo = await ArticleService.create(articulo);
      _todos.add(nuevo);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al agregar artículo: $e');
    }
  }

  Future<void> actualizarArticulo(Article articulo) async {
    try {
      final actualizado = await ArticleService.update(articulo);
      final index = _todos.indexWhere((a) => a.id == actualizado.id);
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar artículo: $e');
    }
  }

  Future<void> eliminarArticulo(int id) async {
    try {
      await ArticleService.delete(id);
      _todos.removeWhere((a) => a.id == id);
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al eliminar artículo: $e');
    }
  }
}
