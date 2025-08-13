/// Modelos para datos del Dashboard
class DashboardSummary {
  final int totalArticles;
  final int totalSuppliers;
  final int totalPurchaseOrders;
  final int totalRequests;
  final int lowStockArticles;
  final int pendingRequests;
  final int pendingOrders;
  final double totalPurchaseValue;

  DashboardSummary({
    required this.totalArticles,
    required this.totalSuppliers,
    required this.totalPurchaseOrders,
    required this.totalRequests,
    required this.lowStockArticles,
    required this.pendingRequests,
    required this.pendingOrders,
    required this.totalPurchaseValue,
  });
}

/// Datos para PieChart de operaciones
class OperationsPieData {
  final int purchases;
  final int requests;
  final int stockMovements;

  OperationsPieData({
    required this.purchases,
    required this.requests,
    required this.stockMovements,
  });
}

/// Datos mensuales para BarChart
class MonthlyData {
  final String month;
  final int purchases;
  final int requests;
  final double value;

  MonthlyData({
    required this.month,
    required this.purchases,
    required this.requests,
    required this.value,
  });
}

/// Datos por estado para BarChart horizontal
class StatusData {
  final String status;
  final int count;
  final double percentage;

  StatusData({
    required this.status,
    required this.count,
    required this.percentage,
  });
}

/// Alertas del sistema
class SystemAlert {
  final String type; // 'warning', 'error', 'info'
  final String message;
  final int count;
  final String actionLabel;
  final String actionRoute;

  SystemAlert({
    required this.type,
    required this.message,
    required this.count,
    required this.actionLabel,
    required this.actionRoute,
  });
}