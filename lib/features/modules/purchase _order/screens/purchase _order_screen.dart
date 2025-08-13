import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../purchase _order/models/purchase_order_model.dart';
import '../../purchase _order/providers/purchase _order_provider.dart';
import '../../purchase _order/widgets/change_status_dialog.dart';
import '../../purchase _order/widgets/purchase_order_detail_dialog.dart';

class PurchaseOrderScreen extends StatefulWidget {
  static const String name = 'purchase_orders';
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseOrderProvider>().cargarOrdenes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: Consumer<PurchaseOrderProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Header informativo sobre política de órdenes
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Las órdenes de compra no se eliminan por política empresarial. Solo se permite cambiar su estado (generada → procesada → completada).',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tabla de datos
              Expanded(
                child: GenericDataTable<PurchaseOrder>(
        title: 'Órdenes de Compra',
        isLoading: provider.isLoading,
        items: provider.ordenes,
        currentPage: provider.paginaActual,
        totalPages: provider.totalPaginas,
        totalItems: provider.totalRegistros,
        itemsPerPage: provider.registrosPorPagina,
        onPageChanged: provider.cambiarPagina,
        onItemsPerPageChanged: provider.cambiarRegistrosPorPagina,
        onSearch: (value) => provider.busqueda = value,
        columns: [
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.06,
              child: const Text('N° Orden'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.06,
              child: const Text('ID Solicitud'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Fecha'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Estado'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.25,
              child: const Text('Artículos'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.08,
              child: const Text('Total Items'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Costo Total'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.15,
              child: const Text('Acciones'),
            ),
          ),
        ],
        rowBuilder: (items) {
          return items.map((o) {
            // Información consolidada de los items
            final articulosTexto = o.items.isNotEmpty
                ? o.items.take(2).map((item) => '${item.articulo} (${item.cantidad})').join(', ') +
                  (o.items.length > 2 ? ' y ${o.items.length - 2} más...' : '')
                : 'Sin artículos cargados';

            final totalItems = o.items.length;

            final costoTotal = o.items.isNotEmpty && o.estado != PurchaseOrder.ESTADO_GENERADA
              ? o.items.fold<double>(0, (sum, item) => sum + (item.costoUnitario * item.cantidad))
              : 0.0;            return DataRow(
              cells: [
                DataCell(Text(o.numeroOrden.toString())),
                DataCell(Text(o.idSolicitud.toString())),
                DataCell(Text(o.fechaOrden.toIso8601String().split('T').first)),
                DataCell(
                  Chip(
                    side: BorderSide(
                      color: o.estado == PurchaseOrder.ESTADO_COMPLETADA
                          ? AppColors.success
                          : o.estado == PurchaseOrder.ESTADO_CANCELADA
                          ? AppColors.danger
                          : o.estado == PurchaseOrder.ESTADO_PROCESADA
                          ? AppColors.info
                          : AppColors.warning,
                    ),
                    backgroundColor: o.estado == PurchaseOrder.ESTADO_COMPLETADA
                        ? AppColors.success.withValues(alpha: 0.15)
                        : o.estado == PurchaseOrder.ESTADO_CANCELADA
                        ? AppColors.danger.withValues(alpha: 0.15)
                        : o.estado == PurchaseOrder.ESTADO_PROCESADA
                        ? AppColors.info.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    label: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.08,
                      child: Text(
                        o.estado,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: o.estado == PurchaseOrder.ESTADO_COMPLETADA
                              ? AppColors.success
                              : o.estado == PurchaseOrder.ESTADO_CANCELADA
                              ? AppColors.danger
                              : o.estado == PurchaseOrder.ESTADO_PROCESADA
                              ? AppColors.info
                              : AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Tooltip(
                      message: o.items.isNotEmpty
                          ? o.items.map((item) => '${item.articulo} (${item.cantidad} ${item.unidadMedida})').join('\n')
                          : 'Sin artículos disponibles',
                      child: Text(
                        articulosTexto,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      totalItems.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    o.estado == PurchaseOrder.ESTADO_GENERADA 
                      ? 'Pendiente asignación'
                      : costoTotal > 0 ? '\$${costoTotal.toStringAsFixed(2)}' : 'No asignado',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: o.estado == PurchaseOrder.ESTADO_GENERADA
                        ? AppColors.warning
                        : costoTotal > 0 ? AppColors.success : AppColors.gray,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      // Botón para ver detalle
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.blue),
                        tooltip: 'Ver detalle',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => PurchaseOrderDetailDialog(orden: o),
                          );
                        },
                      ),

                      // Menú de opciones
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF10B981)),
                        onSelected: (value) async {
                          if (value == 'change_status') {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (_) => ChangeStatusDialog(
                                orden: o,
                                onStatusChanged: (nuevoEstado, costos) async {
                                  print('=== DEBUG: onStatusChanged ===');
                                  print('Cambiando estado a: $nuevoEstado');
                                  print('Costos: $costos');
                                  
                                  final success = await provider.cambiarEstadoOrden(
                                    numeroOrden: o.numeroOrden,
                                    nuevoEstado: nuevoEstado,
                                    costosPorArticulo: costos,
                                  );
                                  
                                  print('Resultado del cambio: $success');
                                  
                                  // Cerrar el diálogo de forma más segura
                                  if (context.mounted) {
                                    try {
                                      // Verificar que podemos hacer pop antes de intentarlo
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                        print('Diálogo cerrado exitosamente');
                                      } else {
                                        print('No se puede cerrar diálogo - No hay rutas en la pila');
                                      }
                                    } catch (e) {
                                      print('Error al cerrar diálogo: $e');
                                      // Intento alternativo: usar Navigator.of(context, rootNavigator: true)
                                      try {
                                        if (Navigator.of(context, rootNavigator: true).canPop()) {
                                          Navigator.of(context, rootNavigator: true).pop();
                                          print('Diálogo cerrado con rootNavigator');
                                        }
                                      } catch (e2) {
                                        print('Error con rootNavigator: $e2');
                                      }
                                    }
                                  }
                                  
                                  // Esperar antes de mostrar el mensaje
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  
                                  if (context.mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✅ Estado cambiado exitosamente a "$nuevoEstado". Los datos se han actualizado automáticamente.'),
                                          backgroundColor: AppColors.success,
                                          duration: Duration(seconds: 4),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('❌ Error al cambiar estado. Verifique la conexión al servidor.'),
                                          backgroundColor: AppColors.danger,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            );

                            if (result == true) {
                              provider.cargarOrdenes();
                            }
                          }
                          // NOTA: Opción de eliminar removida por reglas de negocio
                          // Las órdenes de compra no se eliminan, solo cambian de estado
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'change_status',
                            child: ListTile(
                              leading: Icon(Icons.assignment_turned_in, color: Colors.orange),
                              title: Text('Cambiar Estado'),
                            ),
                          ),
                          // NOTA: Eliminación removida por reglas de negocio
                          // Las órdenes de compra no se eliminan, solo cambian de estado
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList();
        },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
