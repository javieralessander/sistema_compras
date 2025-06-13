import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_compras/features/modules/article/screens/article_screen.dart';
import 'package:sistema_compras/features/modules/purchase%20_order/screens/purchase%20_order_screen.dart';
import 'package:sistema_compras/features/modules/request_articles/screens/request_articles_screen.dart';
import 'package:sistema_compras/features/modules/supplier/screens/supplier_screen.dart';
import '../../../core/config/app_theme.dart';
import '../../../shared/widgets/generic_appbar.dart';
import '../widgets/bar_chart_sample7.dart';
import '../widgets/pie_chart_sample3.dart';
import '../widgets/bar_chart_sample4.dart';

class HomeScreen extends StatefulWidget {
  static const String name = 'home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showAssistant = false;

  // Datos para BarChartSample7
  final List<BarData> barData7 = const [
    BarData(AppColors.contentColorOrange, 10, 15),
    BarData(AppColors.contentColorPink, 2.5, 5),
    BarData(AppColors.contentColorRed, 2, 2),
    BarData(AppColors.contentColorGreen, 8, 10),
    BarData(AppColors.contentColorBlue, 6, 8),
  ];

  // Datos de ejemplo para el gráfico de barras (sin usar fl_chart aquí)
  final List<CustomBarChartData> barData = [
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 3, Colors.blue)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 4, Colors.orange)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 2, Colors.purple)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 5, Colors.teal)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 6, Colors.cyan)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 8, Colors.indigo)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 7, Colors.red)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 9, Colors.green)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 10, Colors.yellow)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 5, Colors.pink)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 4, Colors.lightGreen)],
      ],
    ),
    CustomBarChartData(
      stackedRods: [
        [CustomRodStackItem(0, 3, Colors.lime)],
      ],
    ),
  ];

  final List<String> barLabels = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          isMobile || showAssistant
              ? null // Ocultar FAB en pantallas móviles
              : FloatingActionButton.extended(
                heroTag: 'chat_assistant',
                backgroundColor: Colors.blue,
                icon: const Icon(Icons.support_agent),
                label: const Text('Soporte'),
                onPressed: () => setState(() => showAssistant = true),
              ),
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            // CONTENIDO PRINCIPAL
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --------- ALERTAS EN FRANJA SUPERIOR ---------
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '¡Atención! 2 productos con stock bajo. 1 compra pendiente de aprobación.',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Ver detalles'),
                        ),
                      ],
                    ),
                  ),
                  // --------- ACCESOS RÁPIDOS ---------
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Nueva Compra'),
                        onPressed: () {
                          context.pushReplacementNamed(PurchaseOrderScreen.name);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.point_of_sale),
                        label: const Text('Nueva Solicitud'),
                        onPressed: () {
                          context.pushReplacementNamed(RequestArticlesScreen.name);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.inventory),
                        label: const Text('Nuevo Producto'),
                        onPressed: () {
                            context.pushReplacementNamed(ArticleScreen.name);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.people),
                        label: const Text('Proveedores'),
                        onPressed: () {
                          context.pushReplacementNamed(SupplierScreen.name);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // --------- GRÁFICOS PRINCIPALES ---------
                  Center(
                    child: Wrap(
                      spacing: 32,
                      runSpacing: 32,
                      alignment: WrapAlignment.center,
                      children: [
                        // Tarjeta PieChart
                        Container(
                          width: isMobile ? double.infinity : 400,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: isMobile ? 300 : 400,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Resumen de Operaciones',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: PieChartCustom(
                                    data: [
                                      PieChartSectionModel(
                                        value: 40,
                                        title: 'Compras',
                                        color: Colors.blue,
                                        svgAsset:
                                            'assets/icons/shopping_cart.svg',
                                      ),
                                      PieChartSectionModel(
                                        value: 30,
                                        title: 'Ventas',
                                        color: Colors.green,
                                        svgAsset: 'assets/icons/sell.svg',
                                      ),
                                      PieChartSectionModel(
                                        value: 30,
                                        title: 'Stock',
                                        color: Colors.orange,
                                        svgAsset: 'assets/icons/warehouse.svg',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tarjeta BarChart vertical
                        Container(
                          width: isMobile ? double.infinity : 500,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: isMobile ? 300 : 400,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Evolución Mensual',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: CustomBarChart(
                                    data: barData,
                                    bottomLabels: barLabels,
                                    gridColor: Colors.grey.shade300,
                                    maxY: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Tarjeta BarChart horizontal
                        Container(
                          width: isMobile ? double.infinity : 500,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: isMobile ? 300 : 400,
                            child: BarChartSample7(
                              dataList: barData7,
                              title: 'Horizontal Bar Chart',
                              maxY: 20,
                              shadowColor: AppColors.borderColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: sizeScreen.height * 0.5),

            // PANEL LATERAL ASISTENTE/CHAT
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: 0,
              bottom: 0,
              // Cambia 'left' por 'right'
              right: showAssistant ? 0 : -350,
              width: 350,
              child: Material(
                elevation: 16,
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.support_agent,
                          color: Colors.blue,
                        ),
                        title: const Text('Asistente de Soporte'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed:
                              () => setState(() => showAssistant = false),
                        ),
                      ),
                      const Divider(),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Aquí irá tu chat de soporte o asistente virtual.\nPuedes integrar mensajes, historial, etc.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Escribe tu mensaje...',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
