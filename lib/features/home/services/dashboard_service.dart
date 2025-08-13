import 'package:sistema_compras/core/config/http_api_client.dart';
import '../models/dashboard_models.dart';
import '../../modules/article/models/article_model.dart';
import '../../modules/supplier/models/supplier_model.dart';
import '../../modules/purchase _order/models/purchase_order_model.dart';
import '../../modules/request_articles/models/request_articles_model.dart';

class DashboardService {
  final HttpApiClient _httpClient;
  
  DashboardService(this._httpClient);

  /// Obtiene resumen general del dashboard
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      // Hacer llamadas paralelas a todos los endpoints con manejo de errores individual
      final futures = [
        _getAllArticles().catchError((e) {
          print('Error obteniendo artículos: $e');
          return <Article>[];
        }),
        _getAllSuppliers().catchError((e) {
          print('Error obteniendo proveedores: $e');
          return <Supplier>[];
        }),
        _getAllPurchaseOrders().catchError((e) {
          print('Error obteniendo órdenes de compra: $e');
          return <PurchaseOrder>[];
        }),
        _getAllRequests().catchError((e) {
          print('Error obteniendo solicitudes: $e');
          return <RequestArticles>[];
        }),
      ];

      final results = await Future.wait(futures);
      final articles = results[0] as List<Article>;
      final suppliers = results[1] as List<Supplier>;
      final purchaseOrders = results[2] as List<PurchaseOrder>;
      final requests = results[3] as List<RequestArticles>;

      // Calcular métricas
      final lowStockArticles = articles.where((a) => a.existencia < 10).length;
      final pendingRequests = requests.where((r) => r.estado == RequestArticles.ESTADO_PENDIENTE).length;
      final pendingOrders = purchaseOrders.where((po) => po.estado == PurchaseOrder.ESTADO_GENERADA).length;
      
      // Calcular valor total de compras
      double totalPurchaseValue = 0.0;
      for (final order in purchaseOrders) {
        for (final item in order.items) {
          totalPurchaseValue += (item.cantidad * item.costoUnitario);
        }
      }

      return DashboardSummary(
        totalArticles: articles.length,
        totalSuppliers: suppliers.length,
        totalPurchaseOrders: purchaseOrders.length,
        totalRequests: requests.length,
        lowStockArticles: lowStockArticles,
        pendingRequests: pendingRequests,
        pendingOrders: pendingOrders,
        totalPurchaseValue: totalPurchaseValue,
      );
    } catch (e) {
      print('Error obteniendo resumen del dashboard: $e');
      rethrow;
    }
  }

  /// Obtiene datos para el PieChart de operaciones
  Future<OperationsPieData> getOperationsPieData() async {
    try {
      final futures = [
        _getAllPurchaseOrders().catchError((e) {
          print('Error obteniendo órdenes para pie chart: $e');
          return <PurchaseOrder>[];
        }),
        _getAllRequests().catchError((e) {
          print('Error obteniendo solicitudes para pie chart: $e');
          return <RequestArticles>[];
        }),
        _getAllArticles().catchError((e) {
          print('Error obteniendo artículos para pie chart: $e');
          return <Article>[];
        }),
      ];

      final results = await Future.wait(futures);
      final purchaseOrders = results[0] as List<PurchaseOrder>;
      final requests = results[1] as List<RequestArticles>;
      final articles = results[2] as List<Article>;

      // Calcular movimientos de stock basado en existencias
      final stockMovements = articles.fold<int>(0, (sum, article) => sum + article.existencia);

      return OperationsPieData(
        purchases: purchaseOrders.length,
        requests: requests.length,
        stockMovements: stockMovements,
      );
    } catch (e) {
      print('Error obteniendo datos del pie chart: $e');
      // Retornar datos por defecto en caso de error
      return OperationsPieData(
        purchases: 0,
        requests: 0,
        stockMovements: 0,
      );
    }
  }

  /// Obtiene datos mensuales para BarChart
  Future<List<MonthlyData>> getMonthlyData() async {
    try {
      final futures = [
        _getAllPurchaseOrders().catchError((e) {
          print('Error obteniendo órdenes para datos mensuales: $e');
          return <PurchaseOrder>[];
        }),
        _getAllRequests().catchError((e) {
          print('Error obteniendo solicitudes para datos mensuales: $e');
          return <RequestArticles>[];
        }),
      ];

      final results = await Future.wait(futures);
      final purchaseOrders = results[0] as List<PurchaseOrder>;
      final requests = results[1] as List<RequestArticles>;

      // Agrupar por mes los últimos 12 meses
      final now = DateTime.now();
      final monthlyData = <String, MonthlyData>{};

      // Inicializar con meses vacíos
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                     'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      
      for (int i = 0; i < 12; i++) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey = months[month.month - 1];
        monthlyData[monthKey] = MonthlyData(
          month: monthKey,
          purchases: 0,
          requests: 0,
          value: 0.0,
        );
      }

      // Agregar datos de órdenes de compra
      for (final order in purchaseOrders) {
        final monthKey = months[order.fechaOrden.month - 1];
        if (monthlyData.containsKey(monthKey)) {
          double orderValue = 0.0;
          for (final item in order.items) {
            orderValue += (item.cantidad * item.costoUnitario);
          }
          
          monthlyData[monthKey] = MonthlyData(
            month: monthKey,
            purchases: monthlyData[monthKey]!.purchases + 1,
            requests: monthlyData[monthKey]!.requests,
            value: monthlyData[monthKey]!.value + orderValue,
          );
        }
      }

      // Agregar datos de solicitudes
      for (final request in requests) {
        final monthKey = months[request.fechaSolicitud.month - 1];
        if (monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = MonthlyData(
            month: monthKey,
            purchases: monthlyData[monthKey]!.purchases,
            requests: monthlyData[monthKey]!.requests + 1,
            value: monthlyData[monthKey]!.value,
          );
        }
      }

      return monthlyData.values.toList();
    } catch (e) {
      print('Error obteniendo datos mensuales: $e');
      // Retornar datos por defecto
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                     'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      return months.map((month) => MonthlyData(
        month: month,
        purchases: 0,
        requests: 0,
        value: 0.0,
      )).toList();
    }
  }

  /// Obtiene datos por estado para BarChart horizontal
  Future<List<StatusData>> getStatusData() async {
    try {
      final futures = await Future.wait([
        _getAllPurchaseOrders(),
        _getAllRequests(),
      ]);

      final purchaseOrders = futures[0] as List<PurchaseOrder>;
      final requests = futures[1] as List<RequestArticles>;

      final statusCounts = <String, int>{};

      // Contar estados de órdenes de compra
      for (final order in purchaseOrders) {
        statusCounts[order.estado] = (statusCounts[order.estado] ?? 0) + 1;
      }

      // Contar estados de solicitudes
      for (final request in requests) {
        statusCounts[request.estado] = (statusCounts[request.estado] ?? 0) + 1;
      }

      final total = statusCounts.values.fold<int>(0, (sum, count) => sum + count);
      
      return statusCounts.entries.map((entry) {
        return StatusData(
          status: entry.key,
          count: entry.value,
          percentage: total > 0 ? (entry.value / total) * 100 : 0,
        );
      }).toList();
    } catch (e) {
      print('Error obteniendo datos por estado: $e');
      rethrow;
    }
  }

  /// Obtiene alertas del sistema
  Future<List<SystemAlert>> getSystemAlerts() async {
    try {
      final futures = await Future.wait([
        _getAllArticles(),
        _getAllRequests(),
        _getAllPurchaseOrders(),
      ]);

      final articles = futures[0] as List<Article>;
      final requests = futures[1] as List<RequestArticles>;
      final purchaseOrders = futures[2] as List<PurchaseOrder>;

      final alerts = <SystemAlert>[];

      // Alerta de stock bajo
      final lowStockArticles = articles.where((a) => a.existencia < 10).length;
      if (lowStockArticles > 0) {
        alerts.add(SystemAlert(
          type: 'warning',
          message: '$lowStockArticles productos con stock bajo',
          count: lowStockArticles,
          actionLabel: 'Ver inventario',
          actionRoute: '/articulos',
        ));
      }

      // Alerta de solicitudes pendientes
      final pendingRequests = requests.where((r) => r.estado == RequestArticles.ESTADO_PENDIENTE).length;
      if (pendingRequests > 0) {
        alerts.add(SystemAlert(
          type: 'info',
          message: '$pendingRequests solicitudes pendientes de aprobación',
          count: pendingRequests,
          actionLabel: 'Ver solicitudes',
          actionRoute: '/solicitud-articulos',
        ));
      }

      // Alerta de órdenes pendientes
      final pendingOrders = purchaseOrders.where((po) => po.estado == PurchaseOrder.ESTADO_GENERADA).length;
      if (pendingOrders > 0) {
        alerts.add(SystemAlert(
          type: 'info',
          message: '$pendingOrders órdenes de compra pendientes',
          count: pendingOrders,
          actionLabel: 'Ver órdenes',
          actionRoute: '/ordenes-compra',
        ));
      }

      return alerts;
    } catch (e) {
      print('Error obteniendo alertas del sistema: $e');
      rethrow;
    }
  }

  // Métodos privados para obtener datos de endpoints específicos
  Future<List<Article>> _getAllArticles() async {
    return await _httpClient.getList<Article>('/articulos', (json) => Article.fromJson(json));
  }

  Future<List<Supplier>> _getAllSuppliers() async {
    return await _httpClient.getList<Supplier>('/proveedores', (json) => Supplier.fromJson(json));
  }

  Future<List<PurchaseOrder>> _getAllPurchaseOrders() async {
    return await _httpClient.getList<PurchaseOrder>('/ordenescompra', (json) => PurchaseOrder.fromJson(json));
  }

  Future<List<RequestArticles>> _getAllRequests() async {
    return await _httpClient.getList<RequestArticles>('/solicitudes', (json) => RequestArticles.fromJson(json));
  }
}