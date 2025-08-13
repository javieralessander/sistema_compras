import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/widgets/status_widget.dart';
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
    final provider = context.watch<PurchaseOrderProvider>();
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<PurchaseOrder>(
        title: provider.ordenes.any((o) => o.items.any((item) => item.cantidad <= 0))
            ? '⚠️ Órdenes de Compra - PROBLEMAS DE CANTIDADES DETECTADOS'
            : 'Órdenes de Compra',
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
            // Detectar problemas de cantidades
            final itemsConProblemas = o.items.where((item) => item.cantidad <= 0).length;
            final tieneCantidadesNulas = itemsConProblemas > 0;
            
            // Información consolidada de los items
            final articulosTexto = o.items.isNotEmpty 
                ? o.items.take(2).map((item) {
                    final cantidadDisplay = item.cantidad <= 0 ? '⚠️NULL' : '${item.cantidad}';
                    return '${item.articulo} ($cantidadDisplay)';
                  }).join(', ') + 
                  (o.items.length > 2 ? ' y ${o.items.length - 2} más...' : '')
                : 'Sin artículos cargados';
            
            final totalItems = o.items.length;
                
            // Cálculo de costo total solo para items con cantidades válidas
            final costoTotal = o.items.isNotEmpty 
                ? o.items.fold<double>(0, (sum, item) {
                    // Solo incluir en el cálculo items con cantidad válida
                    return item.cantidad > 0 ? sum + (item.costoUnitario * item.cantidad) : sum;
                  })
                : 0.0;
            
            return DataRow(
              cells: [
                DataCell(Text(o.numeroOrden.toString())),
                DataCell(Text(o.idSolicitud.toString())),
                DataCell(Text(o.fechaOrden.toIso8601String().split('T').first)),
                DataCell(
                  StatusChip.purchaseOrder(
                    o.estado,
                    width: MediaQuery.of(context).size.width * 0.08,
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
                      color: tieneCantidadesNulas 
                          ? Colors.orange.withValues(alpha: 0.1)
                          : AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: tieneCantidadesNulas 
                          ? Border.all(color: Colors.orange, width: 1)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tieneCantidadesNulas) ...[
                          Icon(Icons.warning, size: 14, color: Colors.orange),
                          SizedBox(width: 4),
                        ],
                        Text(
                          tieneCantidadesNulas 
                              ? '$totalItems (${itemsConProblemas} ⚠️)'
                              : totalItems.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: tieneCantidadesNulas ? Colors.orange : AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        costoTotal > 0 ? '\$${costoTotal.toStringAsFixed(2)}' : 'No asignado',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: costoTotal > 0 ? AppColors.success : AppColors.gray,
                        ),
                      ),
                      if (tieneCantidadesNulas) ...[
                        SizedBox(height: 2),
                        Text(
                          'Cantidades NULL detectadas',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
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
                          if (value == 'view_details') {
                            showDialog(
                              context: context,
                              builder: (context) => PurchaseOrderDetailDialog(orden: o),
                            );
                          } else if (value == 'change_status') {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (_) => ChangeStatusDialog(
                                orden: o,
                                onStatusChanged: (nuevoEstado, costos) async {
                                  try {
                                    print('🔄 Iniciando cambio de estado de ${o.numeroOrden} a $nuevoEstado');
                                    await provider.cambiarEstadoOrden(
                                      numeroOrden: o.numeroOrden,
                                      nuevoEstado: nuevoEstado,
                                      costosPorArticulo: costos,
                                    );
                                    
                                    if (context.mounted) {
                                      // Verificar si podemos hacer pop de forma segura
                                      if (Navigator.canPop(context)) {
                                        Navigator.of(context).pop(true);
                                      } else {
                                        try {
                                          Navigator.of(context, rootNavigator: true).pop(true);
                                        } catch (navError) {
                                          print('⚠️ Error al cerrar diálogo después de éxito: $navError');
                                        }
                                      }
                                      
                                      // Mostrar mensaje de éxito con un delay para asegurar navegación
                                      Future.delayed(Duration(milliseconds: 100), () {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Estado cambiado exitosamente'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  } catch (e) {
                                    print('❌ Error al cambiar estado: $e');
                                    if (context.mounted) {
                                      // Verificar si podemos hacer pop de forma segura
                                      if (Navigator.canPop(context)) {
                                        Navigator.of(context).pop(false);
                                      } else {
                                        try {
                                          Navigator.of(context, rootNavigator: true).pop(false);
                                        } catch (navError) {
                                          print('⚠️ Error al cerrar diálogo después de error: $navError');
                                        }
                                      }
                                      
                                      // Mostrar mensaje de error con un delay
                                      Future.delayed(Duration(milliseconds: 100), () {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error al cambiar estado: $e'),
                                              backgroundColor: AppColors.danger,
                                            ),
                                          );
                                        }
                                      });
                                    }
                                  }
                                },
                              ),
                            );
                            
                            if (result == true) {
                              // Recargar las órdenes después del cambio de estado
                              provider.cargarOrdenes();
                            }
                          } else if (value == 'edit') {
                            await showDialog(
                              context: context,
                              builder: (_) => GenericFormDialog<PurchaseOrder>(
                                title: 'Editar Orden de Compra',
                                initialData: o,
                                onSubmit: (data) async {
                                  await context.read<PurchaseOrderProvider>().actualizarOrden(data);
                                },
                                fromValues: (values, initial) {
                                  final item = initial?.items.isNotEmpty == true ? initial!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: initial?.numeroOrden ?? 0,
                                    idSolicitud: int.tryParse(values['idSolicitud'] ?? '') ?? initial?.idSolicitud ?? 0,
                                    fechaOrden: DateTime.tryParse(values['fechaOrden'] ?? '') ?? initial?.fechaOrden ?? DateTime.now(),
                                    estado: values['estado'] ?? initial?.estado ?? PurchaseOrder.ESTADO_GENERADA,
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: values['articulo'] ?? item?.articulo ?? '',
                                        cantidad: int.tryParse(values['cantidad'] ?? '') ?? item?.cantidad ?? 0,
                                        unidadMedida: values['unidadMedida'] ?? item?.unidadMedida ?? '',
                                        marca: values['marca'] ?? item?.marca ?? '',
                                        costoUnitario: double.tryParse(values['costoUnitario'] ?? '') ?? item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                                fields: [
                                  FormFieldDefinition<PurchaseOrder>(
                                    key: 'idSolicitud',
                                    label: 'ID Solicitud',
                                    getValue: (p) => p?.idSolicitud.toString() ?? '',
                                    applyValue: (p, v) => p!,
                                    validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                                  ),
                                  FormFieldDefinition<PurchaseOrder>(
                                    key: 'fechaOrden',
                                    label: 'Fecha Orden',
                                    fieldType: 'date',
                                    getValue: (p) => p?.fechaOrden,
                                    applyValue: (p, v) => p!,
                                  ),
                                  FormFieldDefinition<PurchaseOrder>(
                                    key: 'estado',
                                    label: 'Estado',
                                    fieldType: 'dropdown',
                                    options: [
                                      PurchaseOrder.ESTADO_GENERADA,
                                      PurchaseOrder.ESTADO_PROCESADA,
                                      PurchaseOrder.ESTADO_COMPLETADA,
                                      PurchaseOrder.ESTADO_CANCELADA,
                                    ],
                                    getValue: (p) => p?.estado ?? PurchaseOrder.ESTADO_GENERADA,
                                    applyValue: (p, v) => p!,
                                  ),
                                  FormFieldDefinition<PurchaseOrder>(
                                    key: 'articulo',
                                    label: 'Artículo (primer item)',
                                    getValue: (p) => p?.items.isNotEmpty == true ? p!.items.first.articulo : '',
                                    applyValue: (p, v) => p!,
                                  ),
                                  FormFieldDefinition<PurchaseOrder>(
                                    key: 'cantidad',
                                    label: 'Cantidad (primer item)',
                                    getValue: (p) => p?.items.isNotEmpty == true ? p!.items.first.cantidad.toString() : '',
                                    applyValue: (p, v) => p!,
                                  ),
                                  FormFieldDefinition<PurchaseOrder>(
                                    key: 'marca',
                                    label: 'Marca (primer item)',
                                    getValue: (p) => p?.items.isNotEmpty == true ? p!.items.first.marca : '',
                                    applyValue: (p, v) => p!,
                                  ),
                                  FormFieldDefinition<PurchaseOrder>(
                                    key: 'costoUnitario',
                                    label: 'Costo Unitario (primer item)',
                                    getValue: (p) => p?.items.isNotEmpty == true ? p!.items.first.costoUnitario.toString() : '',
                                    applyValue: (p, v) => p!,
                                  ),
                                ],
                              ),
                            );
                          } else if (value == 'repair_quantities') {
                            // Mostrar diálogo de confirmación para reparar cantidades
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(Icons.build, color: Colors.purple),
                                    SizedBox(width: 8),
                                    Text('Reparar Cantidades'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Esta orden tiene items con cantidades NULL o 0:'),
                                    SizedBox(height: 8),
                                    ...o.items.where((item) => item.cantidad <= 0).map((item) => 
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            Icon(Icons.warning, color: Colors.orange, size: 16),
                                            SizedBox(width: 4),
                                            Expanded(child: Text('${item.articulo}: cantidad ${item.cantidad}')),
                                          ],
                                        ),
                                      ),
                                    ).toList(),
                                    SizedBox(height: 12),
                                    Text('¿Deseas analizar y reportar el problema de cantidades?'),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.orange.shade200),
                                      ),
                                      child: Text(
                                        'Nota: Esto es un análisis temporal. Se requiere corrección en el backend.',
                                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Analizar'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              try {
                                final success = await provider.repararCantidadesOrden(o.numeroOrden);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success 
                                        ? 'Análisis completado. Ver consola para detalles.'
                                        : 'Error en el análisis de cantidades'),
                                      backgroundColor: success ? Colors.purple : AppColors.danger,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppColors.danger,
                                    ),
                                  );
                                }
                              }
                            }
                          } else if (value == 'inspect_request') {
                            // Inspeccionar la solicitud original
                            try {
                              await provider.inspeccionarSolicitud(o.idSolicitud);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Inspección completada. Ver consola para detalles de solicitud #${o.idSolicitud}'),
                                    backgroundColor: Colors.teal,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error inspeccionando solicitud: $e'),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            }
                          } else if (value == 'compare_endpoints') {
                            // Comparar endpoints para debugging avanzado
                            try {
                              await provider.compararEndpoints(o.numeroOrden);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Comparación completada. Ver consola para análisis detallado de endpoints.'),
                                    backgroundColor: Colors.indigo,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error comparando endpoints: $e'),
                                    backgroundColor: AppColors.danger,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view_details',
                            child: ListTile(
                              leading: Icon(Icons.visibility, color: Colors.green),
                              title: Text('Ver Detalles'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'change_status',
                            child: ListTile(
                              leading: Icon(Icons.assignment_turned_in, color: Colors.orange),
                              title: Text('Cambiar Estado'),
                            ),
                          ),
                          // Mostrar opción de reparar cantidades solo si hay items con cantidad 0 o null
                          if (o.items.any((item) => item.cantidad <= 0))
                            const PopupMenuItem(
                              value: 'repair_quantities',
                              child: ListTile(
                                leading: Icon(Icons.build, color: Colors.purple),
                                title: Text('Reparar Cantidades'),
                                subtitle: Text('Corregir cantidades NULL'),
                              ),
                            ),
                          // Opción para inspeccionar la solicitud original
                          PopupMenuItem(
                            value: 'inspect_request',
                            child: ListTile(
                              leading: Icon(Icons.search, color: Colors.teal),
                              title: Text('Inspeccionar Solicitud'),
                              subtitle: Text('Ver solicitud #${o.idSolicitud}'),
                            ),
                          ),
                          // Opción para comparar endpoints (debugging avanzado)
                          PopupMenuItem(
                            value: 'compare_endpoints',
                            child: ListTile(
                              leading: Icon(Icons.compare_arrows, color: Colors.indigo),
                              title: Text('Comparar Endpoints'),
                              subtitle: Text('getById vs getAll'),
                            ),
                          ),
                          // Solo permitir edición si la orden no está en estado final
                          if (o.estado != PurchaseOrder.ESTADO_COMPLETADA && 
                              o.estado != PurchaseOrder.ESTADO_CANCELADA)
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit, color: Colors.blue),
                                title: Text('Editar'),
                              ),
                            ),
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
    );
  }
}
