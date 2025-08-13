import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';
import '../widgets/pie_chart_sample3.dart'; // Para PieChartSectionModel
import '../widgets/bar_chart_sample4.dart'; // Para CustomBarChartData

class DashboardProvider extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardProvider(this._dashboardService);

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Datos del dashboard
  DashboardSummary? _summary;
  DashboardSummary? get summary => _summary;

  List<SystemAlert> _alerts = [];
  List<SystemAlert> get alerts => _alerts;

  // Datos para los gráficos
  List<PieChartSectionModel> _pieChartData = [];
  List<PieChartSectionModel> get pieChartData => _pieChartData;

  List<CustomBarChartData> _barChartData = [];
  List<CustomBarChartData> get barChartData => _barChartData;

  List<String> _barLabels = [];
  List<String> get barLabels => _barLabels;

  List<StatusData> _statusData = [];
  List<StatusData> get statusData => _statusData;

  String? _error;
  String? get error => _error;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  /// Cargar todos los datos del dashboard
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cargar datos en paralelo
      final futures = [
        _dashboardService.getDashboardSummary(),
        _dashboardService.getSystemAlerts(),
        _dashboardService.getOperationsPieData(),
        _dashboardService.getMonthlyData(),
        _dashboardService.getStatusData(),
      ];

      final results = await Future.wait(futures, eagerError: false);

      // Procesar resultados con manejo de errores individual
      _summary = results[0] as DashboardSummary? ?? DashboardSummary(
        totalArticles: 0,
        totalSuppliers: 0,
        totalPurchaseOrders: 0,
        totalRequests: 0,
        lowStockArticles: 0,
        pendingRequests: 0,
        pendingOrders: 0,
        totalPurchaseValue: 0.0,
      );

      _alerts = results[1] as List<SystemAlert>? ?? [];
      
      final pieData = results[2] as OperationsPieData? ?? OperationsPieData(
        purchases: 5,
        requests: 3,
        stockMovements: 15,
      );
      
      final monthlyData = results[3] as List<MonthlyData>? ?? [];
      _statusData = results[4] as List<StatusData>? ?? [];

      // Convertir datos para los gráficos
      _convertPieChartData(pieData);
      _convertBarChartData(monthlyData);

      print('Dashboard cargado exitosamente:');
      print('- Artículos: ${_summary?.totalArticles}');
      print('- Proveedores: ${_summary?.totalSuppliers}');
      print('- Órdenes: ${_summary?.totalPurchaseOrders}');
      print('- Solicitudes: ${_summary?.totalRequests}');

      _lastUpdated = DateTime.now();

    } catch (e) {
      _error = 'Error cargando datos del dashboard: $e';
      print(_error);
      
      // Cargar datos de ejemplo si hay error
      _loadSampleData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga datos de ejemplo cuando fallan los endpoints
  void _loadSampleData() {
    print('Cargando datos de ejemplo...');
    
    _summary = DashboardSummary(
      totalArticles: 25,
      totalSuppliers: 8,
      totalPurchaseOrders: 12,
      totalRequests: 15,
      lowStockArticles: 3,
      pendingRequests: 5,
      pendingOrders: 2,
      totalPurchaseValue: 45000.0,
    );

    _alerts = [
      SystemAlert(
        type: 'warning',
        message: '3 productos con stock bajo (datos de ejemplo)',
        count: 3,
        actionLabel: 'Ver inventario',
        actionRoute: '/articulos',
      ),
      SystemAlert(
        type: 'info',
        message: '5 solicitudes pendientes (datos de ejemplo)',
        count: 5,
        actionLabel: 'Ver solicitudes',
        actionRoute: '/solicitud-articulos',
      ),
    ];

    // Datos de ejemplo para pie chart
    _convertPieChartData(OperationsPieData(
      purchases: 12,
      requests: 15,
      stockMovements: 80,
    ));

    // Datos de ejemplo para bar chart
    final sampleMonthlyData = [
      MonthlyData(month: 'Ene', purchases: 3, requests: 5, value: 5000.0),
      MonthlyData(month: 'Feb', purchases: 4, requests: 3, value: 7000.0),
      MonthlyData(month: 'Mar', purchases: 2, requests: 6, value: 3500.0),
      MonthlyData(month: 'Abr', purchases: 5, requests: 4, value: 8500.0),
      MonthlyData(month: 'May', purchases: 6, requests: 7, value: 9200.0),
      MonthlyData(month: 'Jun', purchases: 3, requests: 2, value: 4500.0),
      MonthlyData(month: 'Jul', purchases: 4, requests: 5, value: 6800.0),
      MonthlyData(month: 'Ago', purchases: 7, requests: 8, value: 11000.0),
      MonthlyData(month: 'Sep', purchases: 2, requests: 3, value: 3200.0),
      MonthlyData(month: 'Oct', purchases: 5, requests: 6, value: 7500.0),
      MonthlyData(month: 'Nov', purchases: 8, requests: 4, value: 12000.0),
      MonthlyData(month: 'Dic', purchases: 6, requests: 9, value: 9800.0),
    ];
    _convertBarChartData(sampleMonthlyData);

    _statusData = [
      StatusData(status: 'pendiente', count: 7, percentage: 35),
      StatusData(status: 'procesada', count: 8, percentage: 40),
      StatusData(status: 'completada', count: 4, percentage: 20),
      StatusData(status: 'cancelada', count: 1, percentage: 5),
    ];
  }

  /// Convertir datos para PieChart
  void _convertPieChartData(OperationsPieData data) {
    final total = data.purchases + data.requests + (data.stockMovements / 100).round();
    
    _pieChartData = [
      PieChartSectionModel(
        value: total > 0 ? (data.purchases / total) * 100 : 0,
        title: 'Compras',
        color: const Color(0xFF2196F3), // Azul
        svgAsset: 'assets/icons/shopping_cart.svg',
      ),
      PieChartSectionModel(
        value: total > 0 ? (data.requests / total) * 100 : 0,
        title: 'Solicitudes',
        color: const Color(0xFF4CAF50), // Verde
        svgAsset: 'assets/icons/sell.svg',
      ),
      PieChartSectionModel(
        value: total > 0 ? ((data.stockMovements / 100).round() / total) * 100 : 0,
        title: 'Stock',
        color: const Color(0xFFFF9800), // Naranja
        svgAsset: 'assets/icons/warehouse.svg',
      ),
    ];
  }

  /// Convertir datos mensuales para BarChart
  void _convertBarChartData(List<MonthlyData> monthlyData) {
    // Ordenar por orden de meses
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    final sortedData = <MonthlyData>[];
    for (final month in months) {
      final data = monthlyData.firstWhere(
        (d) => d.month == month,
        orElse: () => MonthlyData(month: month, purchases: 0, requests: 0, value: 0.0),
      );
      sortedData.add(data);
    }

    _barLabels = sortedData.map((d) => d.month).toList();
    
    _barChartData = sortedData.map((data) {
      return CustomBarChartData(
        stackedRods: [
          [
            CustomRodStackItem(
              0, 
              data.purchases.toDouble(), 
              const Color(0xFF2196F3), // Azul para compras
            ),
          ],
        ],
      );
    }).toList();
  }

  /// Recargar solo las alertas
  Future<void> refreshAlerts() async {
    try {
      _alerts = await _dashboardService.getSystemAlerts();
      notifyListeners();
    } catch (e) {
      print('Error refrescando alertas: $e');
    }
  }

  /// Obtener el primer mensaje de alerta para mostrar en la UI
  String getMainAlertMessage() {
    if (_alerts.isEmpty) return '';
    
    final warningAlerts = _alerts.where((a) => a.type == 'warning').toList();
    if (warningAlerts.isNotEmpty) {
      return warningAlerts.first.message;
    }
    
    return _alerts.first.message;
  }

  /// Obtener el total de alertas críticas
  int getCriticalAlertsCount() {
    return _alerts.where((a) => a.type == 'warning' || a.type == 'error').length;
  }

  /// Limpiar datos (útil para logout o cambio de usuario)
  void clearData() {
    _summary = null;
    _alerts.clear();
    _pieChartData.clear();
    _barChartData.clear();
    _barLabels.clear();
    _statusData.clear();
    _error = null;
    notifyListeners();
  }
}