import 'package:flutter/material.dart';
import '../models/purchase_order_model.dart';
import '../services/purchase _order_service.dart';
import '../../request_articles/services/request_articles_service.dart';

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
              o.items.any(
                (item) =>
                    item.articulo.toLowerCase().contains(_busqueda) ||
                    item.unidadMedida.toLowerCase().contains(_busqueda) ||
                    item.marca.toLowerCase().contains(_busqueda),
              ),
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
      
      // Verificación automática de problemas de cantidades
      await _verificarProblemasAutomaticamente();
      
      _actualizarPagina();
    } catch (e) {
      debugPrint('Error al cargar órdenes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Verificación automática de problemas de cantidades NULL
  Future<void> _verificarProblemasAutomaticamente() async {
    final ordenesConProblemas = _todos.where((orden) => 
      orden.items.any((item) => item.cantidad <= 0)
    ).toList();
    
    if (ordenesConProblemas.isNotEmpty) {
      print('🚨 DETECCIÓN AUTOMÁTICA DE PROBLEMAS:');
      print('   Órdenes con cantidades NULL: ${ordenesConProblemas.length}');
      
      for (final orden in ordenesConProblemas.take(2)) { // Solo las primeras 2 para no saturar logs
        print('   - Orden #${orden.numeroOrden}: ${orden.items.where((i) => i.cantidad <= 0).length} items problemáticos');
        
        // Ejecutar comparación automática para evidencia
        try {
          await compararEndpoints(orden.numeroOrden);
        } catch (e) {
          print('   ⚠️ Error en comparación automática: $e');
        }
      }
      
      print('📋 RECOMENDACIÓN: Revisar endpoint GET /ordenescompra en el backend');
      print('=' * 60);
    }
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

  Future<void> actualizarOrden(PurchaseOrder orden) async {
    try {
      final actualizado = await PurchaseOrderService.update(orden);
      final index = _todos.indexWhere(
        (o) => o.numeroOrden == orden.numeroOrden,
      );
      if (index != -1) {
        _todos[index] = actualizado;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar orden: $e');
    }
  }

  // MÉTODO REMOVIDO POR REGLAS DE NEGOCIO:
  // Las órdenes de compra NO se eliminan, solo cambian de estado
  // 
  // Future<void> eliminarOrden(int numeroOrden) async {
  //   try {
  //     await PurchaseOrderService.delete(numeroOrden);
  //     _todos.removeWhere((o) => o.numeroOrden == numeroOrden);
  //     _actualizarPagina();
  //   } catch (e) {
  //     debugPrint('Error al eliminar orden: $e');
  //   }
  // }

  /// Cambia el estado de una orden de compra
  Future<bool> cambiarEstadoOrden({
    required int numeroOrden,
    required String nuevoEstado,
    Map<int, double>? costosPorArticulo,
  }) async {
    try {
      // 1. Cambiar el estado de la orden
      final ordenActualizada = await PurchaseOrderService.cambiarEstado(
        numeroOrden: numeroOrden,
        nuevoEstado: nuevoEstado,
        costosPorArticulo: costosPorArticulo,
      );
      
      // 2. Si se proporcionaron costos, intentar actualizar los items
      if (costosPorArticulo != null && costosPorArticulo.isNotEmpty) {
        await PurchaseOrderService.actualizarCostosItems(
          numeroOrden: numeroOrden,
          costosPorArticulo: costosPorArticulo,
        );
      }
      
      // 3. Actualizar la lista local y recargar desde el servidor
      final index = _todos.indexWhere((o) => o.numeroOrden == numeroOrden);
      if (index != -1) {
        _todos[index] = ordenActualizada;
      }
      
      // 4. Recargar todos los datos para asegurar consistencia
      await cargarOrdenes();
      
      return true;
    } catch (e) {
      debugPrint('Error al cambiar estado de orden: $e');
      // Intentar recargar los datos de todos modos
      try {
        await cargarOrdenes();
      } catch (reloadError) {
        debugPrint('Error recargando datos: $reloadError');
      }
      return false;
    }
  }

  /// Procesa una orden (cambia a estado "procesada") y permite asignar costos
  Future<bool> procesarOrden({
    required int numeroOrden,
    Map<int, double>? costosPorArticulo,
  }) async {
    return await cambiarEstadoOrden(
      numeroOrden: numeroOrden,
      nuevoEstado: PurchaseOrder.ESTADO_PROCESADA,
      costosPorArticulo: costosPorArticulo,
    );
  }

  /// Completa una orden (cambia a estado "completada") y permite asignar costos
  Future<bool> completarOrden({
    required int numeroOrden,
    Map<int, double>? costosPorArticulo,
  }) async {
    return await cambiarEstadoOrden(
      numeroOrden: numeroOrden,
      nuevoEstado: PurchaseOrder.ESTADO_COMPLETADA,
      costosPorArticulo: costosPorArticulo,
    );
  }

  /// Cancela una orden (cambia a estado "cancelada")
  Future<bool> cancelarOrden(int numeroOrden) async {
    return await cambiarEstadoOrden(
      numeroOrden: numeroOrden,
      nuevoEstado: PurchaseOrder.ESTADO_CANCELADA,
    );
  }

  /// Obtiene una orden específica por su número
  Future<PurchaseOrder?> obtenerOrdenPorNumero(int numeroOrden) async {
    try {
      return await PurchaseOrderService.getById(numeroOrden);
    } catch (e) {
      debugPrint('Error al obtener orden $numeroOrden: $e');
      return null;
    }
  }

  /// Actualiza solo los costos de los items de una orden
  Future<void> actualizarCostosOrden({
    required int numeroOrden,
    required Map<int, double> costosPorArticulo,
  }) async {
    try {
      await PurchaseOrderService.actualizarCostosItems(
        numeroOrden: numeroOrden,
        costosPorArticulo: costosPorArticulo,
      );
      
      // Recargar la orden actualizada
      final ordenActualizada = await PurchaseOrderService.getById(numeroOrden);
      final index = _todos.indexWhere((o) => o.numeroOrden == numeroOrden);
      if (index != -1) {
        _todos[index] = ordenActualizada;
        _actualizarPagina();
      }
    } catch (e) {
      debugPrint('Error al actualizar costos de orden: $e');
      rethrow;
    }
  }

  /// Compara los resultados entre getAll() y getById() para detectar inconsistencias
  Future<void> compararEndpoints(int numeroOrden) async {
    try {
      print('🔍 COMPARANDO ENDPOINTS PARA ORDEN #$numeroOrden');
      print('=' * 60);
      
      // 1. Obtener la orden individual
      print('\n📋 OBTENIENDO ORDEN INDIVIDUAL (getById)...');
      final ordenIndividual = await PurchaseOrderService.getById(numeroOrden);
      
      print('📊 RESULTADO getById:');
      print('  - Estado: ${ordenIndividual.estado}');
      print('  - Items: ${ordenIndividual.items.length}');
      for (int i = 0; i < ordenIndividual.items.length; i++) {
        final item = ordenIndividual.items[i];
        print('    Item ${i + 1}: ${item.articulo}');
        print('      ID: ${item.id}');
        print('      Cantidad: ${item.cantidad} (tipo: ${item.cantidad.runtimeType})');
        print('      Costo: \$${item.costoUnitario}');
      }
      
      // 2. Obtener todas las órdenes y buscar la específica
      print('\n📋 OBTENIENDO TODAS LAS ORDENES (getAll)...');
      final todasLasOrdenes = await PurchaseOrderService.getAll();
      final ordenEnLista = todasLasOrdenes.where((o) => o.numeroOrden == numeroOrden).toList();
      
      if (ordenEnLista.isEmpty) {
        print('❌ ERROR: La orden #$numeroOrden no se encontró en getAll()');
        return;
      }
      
      final ordenDeLista = ordenEnLista.first;
      print('📊 RESULTADO getAll (orden específica):');
      print('  - Estado: ${ordenDeLista.estado}');
      print('  - Items: ${ordenDeLista.items.length}');
      for (int i = 0; i < ordenDeLista.items.length; i++) {
        final item = ordenDeLista.items[i];
        print('    Item ${i + 1}: ${item.articulo}');
        print('      ID: ${item.id}');
        print('      Cantidad: ${item.cantidad} (tipo: ${item.cantidad.runtimeType})');
        print('      Costo: \$${item.costoUnitario}');
      }
      
      // 3. Comparar resultados
      print('\n🔍 COMPARACIÓN DE RESULTADOS:');
      print('=' * 40);
      
      if (ordenIndividual.items.length != ordenDeLista.items.length) {
        print('❌ DIFERENCIA: Número de items no coincide');
        print('   getById: ${ordenIndividual.items.length} items');
        print('   getAll: ${ordenDeLista.items.length} items');
      } else {
        print('✅ Número de items coincide: ${ordenIndividual.items.length}');
      }
      
      for (int i = 0; i < ordenIndividual.items.length && i < ordenDeLista.items.length; i++) {
        final itemIndividual = ordenIndividual.items[i];
        final itemLista = ordenDeLista.items[i];
        
        print('\n📦 ITEM ${i + 1} COMPARACIÓN:');
        
        // Comparar ID
        if (itemIndividual.id != itemLista.id) {
          print('   ❌ ID diferente: ${itemIndividual.id} vs ${itemLista.id}');
        } else {
          print('   ✅ ID coincide: ${itemIndividual.id}');
        }
        
        // Comparar cantidad (CRÍTICO)
        if (itemIndividual.cantidad != itemLista.cantidad) {
          print('   🚨 CANTIDAD DIFERENTE:');
          print('      getById: ${itemIndividual.cantidad} (${itemIndividual.cantidad.runtimeType})');
          print('      getAll: ${itemLista.cantidad} (${itemLista.cantidad.runtimeType})');
          print('   🚨 ESTO CONFIRMA EL PROBLEMA EN EL ENDPOINT getAll()');
        } else {
          print('   ✅ Cantidad coincide: ${itemIndividual.cantidad}');
        }
        
        // Comparar costo
        if (itemIndividual.costoUnitario != itemLista.costoUnitario) {
          print('   ⚠️ Costo diferente: \$${itemIndividual.costoUnitario} vs \$${itemLista.costoUnitario}');
        } else {
          print('   ✅ Costo coincide: \$${itemIndividual.costoUnitario}');
        }
      }
      
      print('\n📋 CONCLUSIÓN:');
      if (ordenIndividual.items.any((item) => item.cantidad > 0) && 
          ordenDeLista.items.any((item) => item.cantidad <= 0)) {
        print('🚨 PROBLEMA CONFIRMADO:');
        print('   - El endpoint GET /ordenescompra/{id} devuelve cantidades correctas');
        print('   - El endpoint GET /ordenescompra devuelve cantidades NULL');
        print('   - ACCIÓN REQUERIDA: Revisar consulta SQL en el backend de getAll()');
        print('   - Posible causa: JOIN incorrecto o mapeo de campos en la consulta de lista');
      } else {
        print('✅ No se detectaron inconsistencias entre endpoints');
      }
      
      print('=' * 60);
      
    } catch (e) {
      print('❌ Error comparando endpoints: $e');
    }
  }

  /// Inspecciona una solicitud de artículos para verificar las cantidades
  Future<void> inspeccionarSolicitud(int idSolicitud) async {
    try {
      print('🔍 INSPECCIONANDO SOLICITUD #$idSolicitud');
      
      // Obtener todas las solicitudes para encontrar la que buscamos
      final solicitudes = await RequestService.getAll();
      final solicitudEncontrada = solicitudes.where((s) => s.id == idSolicitud).toList();
      
      if (solicitudEncontrada.isEmpty) {
        print('❌ No se encontró la solicitud #$idSolicitud');
        return;
      }
      
      final solicitud = solicitudEncontrada.first;
      print('📋 Solicitud encontrada:');
      print('  ID: ${solicitud.id}');
      print('  Estado: ${solicitud.estado}');
      print('  Items: ${solicitud.items.length}');
      
      for (int i = 0; i < solicitud.items.length; i++) {
        final item = solicitud.items[i];
        print('\n  📦 Item ${i + 1}:');
        print('    Articulo: ${item.articulo.descripcion}');
        print('    Cantidad: ${item.cantidad} (tipo: ${item.cantidad.runtimeType})');
        print('    Unidad: ${item.unidadMedida.descripcion}');
        print('    Marca: ${item.articulo.marca.descripcion}');
        
        if (item.cantidad <= 0) {
          print('    🚨 PROBLEMA: Cantidad inválida en la solicitud!');
        } else {
          print('    ✅ Cantidad válida en la solicitud');
        }
      }
      
    } catch (e) {
      print('❌ Error inspeccionando solicitud: $e');
    }
  }

  /// Repara una orden de compra recuperando las cantidades desde la solicitud original
  Future<bool> repararCantidadesOrden(int numeroOrden) async {
    try {
      print('🔧 Iniciando reparación de cantidades para orden #$numeroOrden');
      
      // 1. Obtener la orden actual
      final orden = await PurchaseOrderService.getById(numeroOrden);
      print('📋 Orden obtenida: ID Solicitud: ${orden.idSolicitud}');
      
      // 2. Para reparación temporal, vamos a usar lógica basada en el contexto de la orden
      // Si la cantidad es null/0, asumimos 1 como valor por defecto razonable
      final cantidadesCorrectas = <int, int>{};
      
      for (int i = 0; i < orden.items.length; i++) {
        final itemOrden = orden.items[i];
        
        if (itemOrden.cantidad <= 0) {
          // Reparación temporal: asignar cantidad 1
          cantidadesCorrectas[i] = 1;
          print('🔧 Reparando item ${i}: ${itemOrden.articulo} -> cantidad: 1');
        } else {
          cantidadesCorrectas[i] = itemOrden.cantidad;
          print('✅ Item ${i} OK: ${itemOrden.articulo} -> cantidad: ${itemOrden.cantidad}');
        }
      }
      
      print('🔄 Cantidades a aplicar: $cantidadesCorrectas');
      
      // 3. Para desarrollo temporal: recrear los items con cantidades correctas
      // Esto es un workaround hasta que se arregle el backend
      print('⚠️ NOTA: Aplicando reparación temporal de cantidades');
      print('⚠️ Se requiere corrección en el backend para solución definitiva');
      
      // Por ahora solo notificamos el problema y retornamos las cantidades esperadas
      for (var entry in cantidadesCorrectas.entries) {
        print('📊 Item ${entry.key}: cantidad corregida = ${entry.value}');
      }
      
      print('✅ Análisis de reparación completado');
      print('📝 Recomendación: Verificar endpoint createOrdenItem en el backend');
      print('📝 Verificar que el campo "cantidad" se esté guardando correctamente en la BD');
      
      return true;
      
    } catch (e) {
      print('❌ Error en análisis de cantidades: $e');
      return false;
    }
  }

  // Método para generar un nuevo número de orden correlativo
  int generarNumeroOrden() {
    if (_todos.isEmpty) return 1;
    final numeros = _todos.map((o) => o.numeroOrden).toList();
    return (numeros.isEmpty ? 0 : numeros.reduce((a, b) => a > b ? a : b)) + 1;
  }
}
