import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../widgets/pie_chart_sample3.dart';
import '../widgets/bar_chart_sample4.dart';
import '../widgets/bar_chart_sample7.dart';

/// Utilidades para convertir datos de la API a formatos de gráficos
class DashboardDataConverter {
  
  /// Convierte OperationsPieData a PieChartSectionModel para el PieChart
  static List<PieChartSectionModel> convertToPieChart(OperationsPieData data) {
    final total = data.purchases + data.requests + data.stockMovements;
    
    if (total == 0) {
      return [
        PieChartSectionModel(
          value: 100,
          title: 'Sin datos',
          color: Colors.grey,
          svgAsset: 'assets/icons/warehouse.svg',
        ),
      ];
    }

    return [
      PieChartSectionModel(
        value: (data.purchases / total) * 100,
        title: 'Compras (${data.purchases})',
        color: const Color(0xFF2196F3), // Azul
        svgAsset: 'assets/icons/shopping_cart.svg',
      ),
      PieChartSectionModel(
        value: (data.requests / total) * 100,
        title: 'Solicitudes (${data.requests})',
        color: const Color(0xFF4CAF50), // Verde
        svgAsset: 'assets/icons/sell.svg',
      ),
      PieChartSectionModel(
        value: (data.stockMovements / total) * 100,
        title: 'Stock (${data.stockMovements})',
        color: const Color(0xFFFF9800), // Naranja
        svgAsset: 'assets/icons/warehouse.svg',
      ),
    ];
  }

  /// Convierte MonthlyData a CustomBarChartData para el BarChart vertical
  static List<CustomBarChartData> convertToVerticalBarChart(List<MonthlyData> monthlyData) {
    // Ordenar por meses del año
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

    return sortedData.map((data) {
      return CustomBarChartData(
        stackedRods: [
          [
            // Barra para compras (azul)
            CustomRodStackItem(
              0, 
              data.purchases.toDouble(), 
              const Color(0xFF2196F3),
            ),
          ],
        ],
      );
    }).toList();
  }

  /// Convierte MonthlyData con requests para BarChart con dos valores
  static List<CustomBarChartData> convertToStackedBarChart(List<MonthlyData> monthlyData) {
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

    return sortedData.map((data) {
      return CustomBarChartData(
        stackedRods: [
          [
            // Primera barra: Compras (azul)
            CustomRodStackItem(
              0, 
              data.purchases.toDouble(), 
              const Color(0xFF2196F3),
            ),
            // Segunda barra: Solicitudes (verde) - apilada sobre compras
            CustomRodStackItem(
              data.purchases.toDouble(), 
              data.purchases.toDouble() + data.requests.toDouble(), 
              const Color(0xFF4CAF50),
            ),
          ],
        ],
      );
    }).toList();
  }

  /// Convierte StatusData a BarData para el BarChart horizontal
  static List<BarData> convertToHorizontalBarChart(List<StatusData> statusData) {
    if (statusData.isEmpty) {
      return [
        const BarData(Colors.grey, 0, 1),
      ];
    }

    return statusData.map((data) {
      Color color;
      switch (data.status.toLowerCase()) {
        case 'generada':
        case 'pendiente':
          color = const Color(0xFFFF9800); // Naranja
          break;
        case 'procesada':
        case 'aprobada':
          color = const Color(0xFF2196F3); // Azul
          break;
        case 'completada':
          color = const Color(0xFF4CAF50); // Verde
          break;
        case 'cancelada':
        case 'rechazada':
          color = const Color(0xFFF44336); // Rojo
          break;
        default:
          color = Colors.grey;
      }

      return BarData(
        color,
        data.count.toDouble(),
        data.count.toDouble() + 2, // Agregamos un poco de padding visual
      );
    }).toList();
  }

  /// Obtiene los labels de meses en el orden correcto
  static List<String> getMonthLabels() {
    return ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 
            'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  }

  /// Calcula el maxY dinámico basado en los datos
  static double calculateMaxY(List<MonthlyData> monthlyData) {
    if (monthlyData.isEmpty) return 10;
    
    final maxValue = monthlyData.fold<int>(0, (max, data) {
      final combined = data.purchases + data.requests;
      return combined > max ? combined : max;
    });
    
    // Agregar 20% de padding arriba
    return (maxValue * 1.2).ceilToDouble();
  }

  /// Calcula el maxY para gráfico horizontal basado en StatusData
  static double calculateHorizontalMaxY(List<StatusData> statusData) {
    if (statusData.isEmpty) return 10;
    
    final maxValue = statusData.fold<int>(0, (max, data) {
      return data.count > max ? data.count : max;
    });
    
    return (maxValue * 1.2).ceilToDouble();
  }

  /// Genera datos de ejemplo si no hay datos reales (para testing)
  static OperationsPieData generateSamplePieData() {
    return OperationsPieData(
      purchases: 15,
      requests: 8,
      stockMovements: 45,
    );
  }

  /// Genera datos mensuales de ejemplo si no hay datos reales
  static List<MonthlyData> generateSampleMonthlyData() {
    final months = getMonthLabels();
    return months.map((month) {
      return MonthlyData(
        month: month,
        purchases: (3 + (month.hashCode % 8)).abs(),
        requests: (2 + (month.hashCode % 5)).abs(),
        value: (1000 + (month.hashCode % 5000)).abs().toDouble(),
      );
    }).toList();
  }

  /// Genera datos de estado de ejemplo
  static List<StatusData> generateSampleStatusData() {
    return [
      StatusData(status: 'pendiente', count: 5, percentage: 25),
      StatusData(status: 'procesada', count: 10, percentage: 50),
      StatusData(status: 'completada', count: 3, percentage: 15),
      StatusData(status: 'cancelada', count: 2, percentage: 10),
    ];
  }
}
