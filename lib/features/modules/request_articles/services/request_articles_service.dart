import 'package:sistema_compras/core/config/env.dart';
import '../../../../core/config/http_api_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/request_articles_model.dart';
import '../../purchase _order/services/purchase _order_service.dart';

class RequestService {
  static final HttpApiClient _client = HttpApiClient(Environment.apiUrl);

  static Future<List<RequestArticles>> getAll() async {
    return await _client.getList<RequestArticles>(
      '/solicitudes',
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Crea una solicitud base sin items
  static Future<RequestArticles> createSolicitud(RequestArticles solicitud) async {
    // Solo enviar datos básicos de la solicitud
    final solicitudData = {
      'empleadoId': solicitud.empleadoSolicitante.id,
      'fechaSolicitud': solicitud.fechaSolicitud.toIso8601String(),
      'estado': RequestArticles.ESTADO_PENDIENTE, // SIEMPRE pendiente para nuevas solicitudes
      'isActive': solicitud.isActive,
    };
    
    final result = await _client.post<RequestArticles>(
      '/solicitudes',
      solicitudData,
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
    
    return result;
  }

  /// Crea un item individual de solicitud
  /// Endpoint: POST /solicitudes-items
  static Future<void> createSolicitudItem({
    required int solicitudId,
    required int articuloId,
    required int cantidad,
    required int unidadMedidaId,
  }) async {
    final itemData = {
      'solicitudId': solicitudId,
      'articuloId': articuloId,
      'cantidad': cantidad,
      'unidadMedidaId': unidadMedidaId,
    };
    
    await _client.post(
      '/solicitudes-items',
      itemData,
      (e) => e,
    );
  }

  /// Crea una solicitud completa con todos sus items
  static Future<RequestArticles> create(RequestArticles solicitud) async {
    // 1. Crear la solicitud base
    final solicitudCreada = await createSolicitud(solicitud);
    
    // 2. Crear cada item de la solicitud
    for (final item in solicitud.items) {
      await createSolicitudItem(
        solicitudId: solicitudCreada.id,
        articuloId: item.articulo.id,
        cantidad: item.cantidad,
        unidadMedidaId: item.unidadMedida.id,
      );
    }
    
    // 3. Retornar la solicitud completa
    return solicitudCreada.copyWith(items: solicitud.items);
  }

  static Future<void> delete(int id) async {
    await _client.delete('/solicitudes/$id');
  }

  static Future<RequestArticles> update(RequestArticles solicitud) async {
    return await _client.put<RequestArticles>(
      '/solicitudes/${solicitud.id}',
      solicitud.toJsonForUpdate(),
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
  }

  /// Aprobar una solicitud (cambiar estado a "aprobada") y crear orden de compra
  static Future<RequestArticles> aprobar(RequestArticles solicitud, {Map<int, double>? preciosPersonalizados}) async {
    // 1. Actualizar estado de la solicitud
    final solicitudAprobada = solicitud.copyWith(estado: RequestArticles.ESTADO_APROBADA);
    
    final result = await _client.put<RequestArticles>(
      '/solicitudes/${solicitud.id}',
      solicitudAprobada.toJsonForUpdate(),
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
    
    // 2. Crear orden de compra automáticamente
    try {
      Logger.info('Iniciando creación automática de orden de compra...', 'RequestService');
      
      // Las órdenes se crean con costo 0 (estado GENERADA)
      // Los precios se asignan cuando cambian a estado PROCESADA
      await PurchaseOrderService.createFromSolicitud(result);
      Logger.info('Orden de compra creada automáticamente con éxito (costos pendientes de asignación)', 'RequestService');
    } catch (e) {
      Logger.error('Error creando orden de compra', e, null, 'RequestService');
      // La solicitud ya fue aprobada, no fallar por error en orden de compra
    }
    
    return result;
  }

  /// Rechazar/Anular una solicitud (cambiar estado a "rechazada")
  static Future<RequestArticles> rechazar(RequestArticles solicitud) async {
    // Solo actualizar el estado, mantener el resto igual
    final solicitudRechazada = solicitud.copyWith(estado: RequestArticles.ESTADO_RECHAZADA);
    
    final result = await _client.put<RequestArticles>(
      '/solicitudes/${solicitud.id}',
      solicitudRechazada.toJsonForUpdate(),
      (e) => RequestArticles.fromJson(e as Map<String, dynamic>),
    );
    
    return result;
  }
}