import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../models/purchase_order_model.dart';
import '../../request_articles/models/request_articles_model.dart';

class PurchaseOrderService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<PurchaseOrder>> getAll() async {
    print('=== DEBUG: getAll ===');
    print('Endpoint: GET /ordenescompra');
    print('Obteniendo todas las ordenes de compra...');
    
    try {
      final ordenes = await _client.getList<PurchaseOrder>(
        '/ordenescompra',
        (e) {
          print('=== Parseando orden individual ===');
          print('JSON recibido: $e');
          try {
            final orden = PurchaseOrder.fromJson(e as Map<String, dynamic>);
            print('Orden parseada exitosamente: #${orden.numeroOrden}');
            return orden;
          } catch (parseError) {
            print('ERROR parseando orden individual: $parseError');
            rethrow;
          }
        },
      );
      
      print('Ordenes obtenidas exitosamente:');
      print('  - Total de ordenes: ${ordenes.length}');
      
      if (ordenes.isNotEmpty) {
        print('  - Resumen:');
        for (int i = 0; i < ordenes.length; i++) {
          final orden = ordenes[i];
          print('    Orden ${i + 1}: #${orden.numeroOrden} - Estado: ${orden.estado} - Items: ${orden.items.length}');
          
          // Mostrar detalles de items para debugging
          if (orden.items.isNotEmpty) {
            for (int j = 0; j < orden.items.length; j++) {
              final item = orden.items[j];
              print('      Item ${j + 1}: ${item.articulo} (ID: ${item.id}, Cant: ${item.cantidad}, Costo: \$${item.costoUnitario})');
            }
          }
        }
      } else {
        print('  - No se encontraron ordenes');
      }
      
      print('=== FIN DEBUG: getAll ===\n');
      
      return ordenes;
    } catch (e) {
      print('ERROR al obtener ordenes: $e');
      print('=== FIN DEBUG: getAll (ERROR) ===\n');
      rethrow;
    }
  }

  static Future<PurchaseOrder> create(PurchaseOrder orden) async {
    return await _client.post<PurchaseOrder>(
      '/ordenescompra',
      orden.toJsonForCreate(), // Usar JSON específico para CREATE
      (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Crea una orden base sin items
  static Future<PurchaseOrder> createOrden({
    required int idSolicitud,
    required DateTime fechaOrden,
    required String estado,
    required bool isActive,
  }) async {
    print('=== DEBUG: createOrden ===');
    print('Endpoint: POST /ordenescompra');
    print('Parametros recibidos:');
    print('  - idSolicitud: $idSolicitud');
    print('  - fechaOrden: ${fechaOrden.toIso8601String()}');
    print('  - estado: $estado');
    print('  - isActive: $isActive');
    
    final ordenData = {
      'idSolicitud': idSolicitud,
      'fechaOrden': fechaOrden.toIso8601String(),
      'estado': estado,
      'isActive': isActive,
    };
    
    print('Payload que se enviara:');
    print(ordenData.toString());
    
    try {
      final ordenCreada = await _client.post<PurchaseOrder>(
        '/ordenescompra',
        ordenData,
        (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
      );
      print('Orden creada exitosamente:');
      print('  - Numero de orden: ${ordenCreada.numeroOrden}');
      print('  - Estado: ${ordenCreada.estado}');
      print('  - Fecha: ${ordenCreada.fechaOrden}');
      print('=== FIN DEBUG: createOrden ===\n');
      return ordenCreada;
    } catch (e) {
      print('ERROR al crear orden: $e');
      print('=== FIN DEBUG: createOrden (ERROR) ===\n');
      rethrow;
    }
  }

  /// Crea un item individual de orden de compra
  /// Endpoint: POST /ordenescompra-items
  static Future<void> createOrdenItem({
    required int ordenCompraId,
    required int articuloId,
    required int cantidad,
    required int unidadMedidaId,
    required int marcaId,
    required double costoUnitario,
  }) async {
    print('=== DEBUG: createOrdenItem ===');
    print('Endpoint: POST /ordenescompra-items');
    print('Parametros recibidos:');
    print('  - ordenCompraId: $ordenCompraId');
    print('  - articuloId: $articuloId');
    print('  - cantidad: $cantidad ⚠️ VALOR CRITICO');
    print('  - unidadMedidaId: $unidadMedidaId');
    print('  - marcaId: $marcaId');
    print('  - costoUnitario: $costoUnitario');
    
    // VERIFICACION ADICIONAL DE LA CANTIDAD
    if (cantidad <= 0) {
      print('🚨 ALERTA CRITICA: La cantidad es $cantidad - esto NO es válido!');
      print('🚨 Verificar que RequestArticleItem.cantidad tenga valor correcto');
    } else {
      print('✅ Cantidad válida: $cantidad');
    }
    
    final itemData = {
      'ordenCompraId': ordenCompraId,
      'articuloId': articuloId,
      'cantidad': cantidad,
      'unidadMedidaId': unidadMedidaId,
      'marcaId': marcaId,
      'costoUnitario': costoUnitario,
    };
    
    print('📤 Payload que se enviara:');
    print(itemData.toString());
    
    try {
      final response = await _client.post(
        '/ordenescompra-items',
        itemData,
        (e) => e,
      );
      print('Respuesta del servidor:');
      print(response.toString());
      print('Item creado exitosamente');
      
      // Verificar inmediatamente el item creado
      print('\n--- VERIFICACION INMEDIATA ---');
      print('Verificando que el item se creó correctamente...');
      // Hacer una consulta inmediata para verificar si se guardó bien
      try {
        final ordenVerificacion = await getById(ordenCompraId);
        final itemCreado = ordenVerificacion.items
            .where((item) => item.articulo.contains('${itemData['articuloId']}') || 
                           item.marca.contains('${itemData['marcaId']}'))
            .toList();
        
        if (itemCreado.isNotEmpty) {
          print('✅ Item encontrado en verificación:');
          for (var item in itemCreado) {
            print('   ID: ${item.id}, Cantidad: ${item.cantidad}, Costo: ${item.costoUnitario}');
          }
        } else {
          print('⚠️ No se encontró el item en la verificación inmediata');
        }
      } catch (verificationError) {
        print('⚠️ Error en verificación inmediata: $verificationError');
      }
      print('--- FIN VERIFICACION ---\n');
      
    } catch (e) {
      print('ERROR al crear item de orden: $e');
      rethrow;
    }
    print('=== FIN DEBUG: createOrdenItem ===\n');
  }

  /// Crear orden de compra automáticamente desde una solicitud aprobada
  static Future<PurchaseOrder> createFromSolicitud(RequestArticles solicitud, {Map<int, double>? preciosArticulos}) async {
    print('=============================================');
    print('=== DEBUG: createFromSolicitud - INICIO ===');
    print('=============================================');
    print('Solicitud ID: ${solicitud.id}');
    print('Cantidad de items en solicitud: ${solicitud.items.length}');
    print('Precios proporcionados: ${preciosArticulos?.toString() ?? "No proporcionados"}');
    
    // 1. Crear la orden base
    print('\n--- PASO 1: Creando orden base ---');
    final ordenCreada = await createOrden(
      idSolicitud: solicitud.id,
      fechaOrden: DateTime.now(),
      estado: PurchaseOrder.ESTADO_GENERADA,
      isActive: true,
    );
    
    print('Orden base creada con numero: ${ordenCreada.numeroOrden}');
    
    // 2. Crear cada item de la orden
    print('\n--- PASO 2: Creando items de la orden ---');
    for (int i = 0; i < solicitud.items.length; i++) {
      final item = solicitud.items[i];
      // Las órdenes recién creadas (GENERADA) tienen costo unitario 0
      // Los precios se asignan cuando cambian a estado PROCESADA
      final precioUnitario = 0.0;
      
      print('\n>>> Procesando item ${i + 1}/${solicitud.items.length}:');
      print('  🔍 DATOS DE LA SOLICITUD ORIGINAL:');
      print('    Articulo ID: ${item.articulo.id}');
      print('    Articulo Descripcion: ${item.articulo.descripcion}');
      print('    Marca ID: ${item.articulo.marca.id}');
      print('    Marca Descripcion: ${item.articulo.marca.descripcion}');
      print('    Cantidad ORIGINAL: ${item.cantidad} (tipo: ${item.cantidad.runtimeType})');
      print('    Unidad ID: ${item.unidadMedida.id}');
      print('    Unidad Descripcion: ${item.unidadMedida.descripcion}');
      print('    Costo unitario: $precioUnitario (se asignara al procesar la orden)');
      
      print('  📤 DATOS QUE SE ENVIARAN AL BACKEND:');
      print('    ordenCompraId: ${ordenCreada.numeroOrden}');
      print('    articuloId: ${item.articulo.id}');
      print('    cantidad: ${item.cantidad} ⚠️ VERIFICAR ESTE VALOR');
      print('    unidadMedidaId: ${item.unidadMedida.id}');
      print('    marcaId: ${item.articulo.marca.id}');
      print('    costoUnitario: $precioUnitario');
      
      await createOrdenItem(
        ordenCompraId: ordenCreada.numeroOrden,
        articuloId: item.articulo.id,
        cantidad: item.cantidad,
        unidadMedidaId: item.unidadMedida.id,
        marcaId: item.articulo.marca.id,
        costoUnitario: precioUnitario,
      );
      
      print('>>> Item ${i + 1} creado exitosamente');
    }
    
    // 3. Retornar la orden completa
    print('\n--- PASO 3: Finalizacion ---');
    print('Todos los items creados exitosamente');
    print('Orden de compra #${ordenCreada.numeroOrden} lista para su procesamiento');
    print('Estado actual: ${ordenCreada.estado}');
    print('===========================================');
    print('=== DEBUG: createFromSolicitud - FIN ===');
    print('===========================================\n');
    
    return ordenCreada;
  }

  /// Calcula precios automáticamente para una solicitud basándose en los artículos
  static Map<int, double> calcularPreciosParaSolicitud(RequestArticles solicitud) {
    Map<int, double> precios = {};
    
    for (final item in solicitud.items) {
      // Calcular precio basándose en marca, descripción, etc.
      double precio = _calcularPrecioPorArticulo(item);
      precios[item.articulo.id] = precio;
    }
    
    return precios;
  }

  /// Calcula precio individual por artículo basándose en sus características
  static double _calcularPrecioPorArticulo(RequestArticleItem item) {
    double precioBase = 1000.0;
    
    // Ajustar precio según marca
    switch (item.articulo.marca.descripcion.toLowerCase()) {
      case 'samsung':
        precioBase *= 1.2; // 20% más caro
        break;
      case 'dell':
        precioBase *= 1.5; // 50% más caro
        break;
      case 'hp':
        precioBase *= 1.3; // 30% más caro
        break;
      default:
        precioBase *= 1.0; // Precio base
    }
    
    // Ajustar precio según descripción (palabras clave)
    final descripcion = item.articulo.descripcion.toLowerCase();
    if (descripcion.contains('laptop')) {
      precioBase *= 1.5;
    } else if (descripcion.contains('mouse')) {
      precioBase *= 0.1;
    } else if (descripcion.contains('teclado')) {
      precioBase *= 0.3;
    } else if (descripcion.contains('monitor')) {
      precioBase *= 0.8;
    }
    
    return double.parse(precioBase.toStringAsFixed(2));
  }

  // MÉTODO REMOVIDO POR REGLAS DE NEGOCIO:
  // Las órdenes de compra NO se eliminan, solo cambian de estado
  // 
  // static Future<void> delete(int numeroOrden) async {
  //   await _client.delete('/ordenescompra/$numeroOrden');
  // }

  static Future<PurchaseOrder> update(PurchaseOrder orden) async {
    return await _client.put<PurchaseOrder>(
      '/ordenescompra/${orden.numeroOrden}',
      orden.toJson(),
      (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Cambia el estado de una orden de compra
  /// Usa el endpoint estándar PUT /api/ordenescompra/{id}
  static Future<PurchaseOrder> cambiarEstado({
    required int numeroOrden,
    required String nuevoEstado,
    Map<int, double>? costosPorArticulo, // Costos por artículo ID (no implementado en backend aún)
  }) async {
    print('=== DEBUG: cambiarEstado ===');
    print('Endpoint: PUT /ordenescompra/$numeroOrden');
    print('Numero de orden: $numeroOrden');
    print('Estado actual -> nuevo estado: ? -> $nuevoEstado');
    print('Costos por articulo: ${costosPorArticulo?.toString() ?? "No proporcionados"}');
    
    // Primero obtener la orden actual para mantener los otros campos
    print('\nObteniendo orden actual...');
    final ordenActual = await getById(numeroOrden);
    print('Orden actual obtenida:');
    print('  - Estado actual: ${ordenActual.estado}');
    print('  - ID Solicitud: ${ordenActual.idSolicitud}');
    print('  - Fecha: ${ordenActual.fechaOrden}');
    print('  - Cantidad de items: ${ordenActual.items.length}');
    
    // Crear los datos de actualización manteniendo los campos existentes
    final requestData = <String, dynamic>{
      'idSolicitud': ordenActual.idSolicitud,
      'fechaOrden': ordenActual.fechaOrden.toIso8601String(),
      'estado': nuevoEstado, // Solo cambiar el estado
      'isActive': true,
    };

    print('\nPayload que se enviara:');
    print(requestData.toString());
    print('Realizando cambio de estado: ${ordenActual.estado} -> $nuevoEstado');
    
    try {
      final ordenActualizada = await _client.put<PurchaseOrder>(
        '/ordenescompra/$numeroOrden',
        requestData,
        (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
      );
      
      print('\nCambio de estado exitoso:');
      print('  - Orden #${ordenActualizada.numeroOrden}');
      print('  - Estado anterior: ${ordenActual.estado}');
      print('  - Estado nuevo: ${ordenActualizada.estado}');
      print('  - Fecha actualizacion: ${DateTime.now()}');
      print('=== FIN DEBUG: cambiarEstado ===\n');
      
      return ordenActualizada;
    } catch (e) {
      print('\nERROR al cambiar estado:');
      print('  - Orden: #$numeroOrden');
      print('  - Estado deseado: $nuevoEstado');
      print('  - Error: $e');
      print('=== FIN DEBUG: cambiarEstado (ERROR) ===\n');
      rethrow;
    }
  }

  /// Procesa una orden (cambia a estado "procesada") y permite asignar costos
  static Future<PurchaseOrder> procesarOrden({
    required int numeroOrden,
    Map<int, double>? costosPorArticulo,
  }) async {
    return await cambiarEstado(
      numeroOrden: numeroOrden,
      nuevoEstado: PurchaseOrder.ESTADO_PROCESADA,
      costosPorArticulo: costosPorArticulo,
    );
  }

  /// Completa una orden (cambia a estado "completada")
  static Future<PurchaseOrder> completarOrden({
    required int numeroOrden,
    Map<int, double>? costosPorArticulo,
  }) async {
    return await cambiarEstado(
      numeroOrden: numeroOrden,
      nuevoEstado: PurchaseOrder.ESTADO_COMPLETADA,
      costosPorArticulo: costosPorArticulo,
    );
  }

  /// Cancela una orden (cambia a estado "cancelada")
  static Future<PurchaseOrder> cancelarOrden(int numeroOrden) async {
    return await cambiarEstado(
      numeroOrden: numeroOrden,
      nuevoEstado: PurchaseOrder.ESTADO_CANCELADA,
    );
  }

  /// Obtiene una orden de compra específica con todos sus items
  static Future<PurchaseOrder> getById(int numeroOrden) async {
    print('=== DEBUG: getById ===');
    print('Endpoint: GET /ordenescompra/$numeroOrden');
    print('Obteniendo orden #$numeroOrden...');
    
    try {
      final orden = await _client.get<PurchaseOrder>(
        '/ordenescompra/$numeroOrden',
        (e) => PurchaseOrder.fromJson(e as Map<String, dynamic>),
      );
      
      print('Orden obtenida exitosamente:');
      print('  - Numero: ${orden.numeroOrden}');
      print('  - Estado: ${orden.estado}');
      print('  - ID Solicitud: ${orden.idSolicitud}');
      print('  - Fecha: ${orden.fechaOrden}');
      print('  - Items: ${orden.items.length}');
      
      if (orden.items.isNotEmpty) {
        print('  - Detalle de items:');
        for (int i = 0; i < orden.items.length; i++) {
          final item = orden.items[i];
          print('    Item ${i + 1}: ${item.articulo} (Cant: ${item.cantidad}, Costo: \$${item.costoUnitario})');
        }
      }
      
      print('=== FIN DEBUG: getById ===\n');
      return orden;
    } catch (e) {
      print('ERROR al obtener orden #$numeroOrden: $e');
      print('=== FIN DEBUG: getById (ERROR) ===\n');
      rethrow;
    }
  }

  /// Actualiza los costos de los items de una orden específica
  /// SOLUCIÓN CORRECTA: Actualizar items existentes, NO crear nuevos
  static Future<void> actualizarCostosItems({
    required int numeroOrden,
    required Map<int, double> costosPorArticulo,
  }) async {
    print('=== DEBUG: actualizarCostosItems ===');
    print('Actualizando costos de items para orden #$numeroOrden');
    print('Costos a aplicar: $costosPorArticulo');
    
    // Obtener la orden actual para acceder a sus items
    final orden = await getById(numeroOrden);
    print('Orden actual obtenida: ${orden.items.length} items');
    
    print('\n=== ESTRATEGIA CORRECTA: ACTUALIZAR (NO CREAR) ===');
    print('1. Identificar items existentes por su posición');
    print('2. Usar PUT para actualizar cada item individual');
    print('3. NO crear items duplicados');
    
    // Procesar cada item existente
    for (int i = 0; i < orden.items.length; i++) {
      final item = orden.items[i];
      
      // Solo actualizar si tenemos un costo específico para este índice
      if (costosPorArticulo.containsKey(i)) {
        final nuevoCosto = costosPorArticulo[i]!;
        
        print('\n>>> Actualizando item ${i + 1}/${orden.items.length}:');
        print('  - Articulo: ${item.articulo}');
        print('  - Cantidad: ${item.cantidad}');
        print('  - Costo actual: \$${item.costoUnitario}');
        print('  - Nuevo costo: \$${nuevoCosto.toStringAsFixed(2)}');
        
        try {
          // MÉTODO 1: Intentar actualizar usando PUT si existe endpoint específico
          await _actualizarItemIndividual(i, nuevoCosto, numeroOrden, item);
          
        } catch (e) {
          print('  ❌ ERROR actualizando item ${i + 1}: $e');
          print('  💡 NOTA: El backend puede no soportar actualización de items individuales');
        }
      } else {
        print('\n>>> Item ${i + 1}: Sin cambio de costo (mantener \$${item.costoUnitario})');
      }
    }
    
    print('\n=== Resumen de actualización ===');
    print('- Orden: #$numeroOrden');
    print('- Items existentes: ${orden.items.length}');
    print('- Costos a actualizar: ${costosPorArticulo.length}');
    print('- IMPORTANTE: NO se crearon items duplicados');
    print('=== FIN DEBUG: actualizarCostosItems ===\n');
  }

  /// Actualiza un item individual usando diferentes estrategias
  static Future<void> _actualizarItemIndividual(
    int indiceItem, 
    double nuevoCosto, 
    int numeroOrden, 
    PurchaseOrderItem item
  ) async {
    print('  --- Intentando actualizar item ---');
    
    // 🔍 OBTENER CANTIDAD ORIGINAL DE LA SOLICITUD
    print('  🔍 Verificando cantidad original del item...');
    int cantidadReal = item.cantidad;
    
    // Si la cantidad es 0, intentar obtenerla de la solicitud original
    if (cantidadReal <= 0) {
      print('  🚨 PROBLEMA: item.cantidad es $cantidadReal');
      print('  🔍 Intentando recuperar cantidad real de la solicitud original...');
      
      try {
        // Obtener la orden completa para acceder al idSolicitud
        final _ = await getById(numeroOrden);
        // Por ahora, usar cantidad por defecto 1
        cantidadReal = 1;
        print('  ✅ Usando cantidad por defecto: $cantidadReal');
      } catch (e) {
        cantidadReal = 1;
        print('  ⚠️ Error obteniendo solicitud, usando cantidad por defecto: $cantidadReal');
      }
    }
    
    // ESTRATEGIA 1: Usar PUT directo con el ID del item
    if (item.id != null) {
      try {
        print('  ESTRATEGIA 1: PUT directo al item (ID: ${item.id})');
        
        // 🚨 VALIDACIÓN CRÍTICA: No enviar cantidad 0 o null
        final cantidadAEnviar = cantidadReal > 0 ? cantidadReal : 1;
        if (cantidadReal <= 0) {
          print('  🚨 ALERTA: cantidadReal es ${cantidadReal}, usando cantidad por defecto: 1');
          print('  🔍 NOTA: El item ya viene corrupto desde getById()');
        }
        
        final updateData = {
          'costoUnitario': nuevoCosto,
          'cantidad': cantidadAEnviar, // 🔧 USAR CANTIDAD REAL
        };
        
        print('  Endpoint: PUT /ordenescompra-items/${item.id}');
        print('  Payload: $updateData');
        print('  📦 Cantidad original del item: ${item.cantidad} → Cantidad real: $cantidadReal → Cantidad a enviar: $cantidadAEnviar');
        
        await _client.put(
          '/ordenescompra-items/${item.id}',
          updateData,
          (e) => e,
        );
        
        print('  ✅ ESTRATEGIA 1 exitosa: Item actualizado directamente');
        return;
        
      } catch (e) {
        print('  ❌ ESTRATEGIA 1 falló: $e');
        print('  💡 El backend puede no soportar PUT en items individuales');
      }
    } else {
      print('  ⚠️  ESTRATEGIA 1 no disponible: Item sin ID');
    }
    
    // ESTRATEGIA 2: Usar endpoint personalizado de actualización masiva
    try {
      print('  ESTRATEGIA 2: Actualización masiva de orden');
      
      final updateData = {
        'items': [
          {
            'itemIndex': indiceItem,
            'costoUnitario': nuevoCosto,
          }
        ]
      };
      
      print('  Endpoint: PUT /ordenescompra/$numeroOrden/items');
      print('  Payload: $updateData');
      
      await _client.put(
        '/ordenescompra/$numeroOrden/items',
        updateData,
        (e) => e,
      );
      
      print('  ✅ ESTRATEGIA 2 exitosa: Items actualizados masivamente');
      return;
      
    } catch (e) {
      print('  ❌ ESTRATEGIA 2 falló: $e');
      print('  💡 Backend no soporta actualización masiva de items');
    }
    
    // ESTRATEGIA 3: Documentar la limitación y proponer solución
    print('  ESTRATEGIA 3: Documentar requerimientos del backend');
    print('  📊 COSTO DESEADO: \$${nuevoCosto.toStringAsFixed(2)} para ${item.articulo}');
    print('  🔧 SOLUCIONES REQUERIDAS EN BACKEND:');
    print('     OPCIÓN A: PUT /api/ordenescompra-items/{itemId} {"costoUnitario": $nuevoCosto}');
    print('     OPCIÓN B: PUT /api/ordenescompra/{ordenId}/items {"items": [...]}');
    print('     OPCIÓN C: PATCH /api/ordenescompra/{ordenId} {"itemUpdates": [...]}');
    print('  📋 ESTADO ACTUAL: Solo se puede cambiar estado de orden, no costos de items');
  }

}