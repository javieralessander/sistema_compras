import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../models/purchase_order_model.dart';
import '../providers/purchase _order_provider.dart';

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
        topRightWidget: FloatingActionButton.extended(
          onPressed:
              () => showDialog(
                context: context,
                builder:
                    (_) => GenericFormDialog<PurchaseOrder>(
                      title: 'Agregar Orden de Compra',
                      onSubmit: (data) async => provider.agregarOrden(data),
                      fields: [
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'idSolicitud',
                          label: 'ID Solicitud',
                          fieldType: 'number',
                          getValue: (o) => o?.idSolicitud.toString() ?? '',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: int.tryParse(v) ?? 0,
                                fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                estado: o?.estado ?? 'Pendiente',
                                articulo: o?.articulo ?? '',
                                cantidad: o?.cantidad ?? 0,
                                unidadMedida: o?.unidadMedida ?? '',
                                marca: o?.marca ?? '',
                                costoUnitario: o?.costoUnitario ?? 0.0,
                              ),
                        ),
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'fechaOrden',
                          label: 'Fecha Orden',
                          fieldType: 'date',
                          getValue:
                              (o) =>
                                  o?.fechaOrden
                                      .toIso8601String()
                                      .split('T')
                                      .first ??
                                  '',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: o?.idSolicitud ?? 0,
                                fechaOrden:
                                    DateTime.tryParse(v) ?? DateTime.now(),
                                estado: o?.estado ?? 'Pendiente',
                                articulo: o?.articulo ?? '',
                                cantidad: o?.cantidad ?? 0,
                                unidadMedida: o?.unidadMedida ?? '',
                                marca: o?.marca ?? '',
                                costoUnitario: o?.costoUnitario ?? 0.0,
                              ),
                        ),
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'estado',
                          label: 'Estado',
                          fieldType: 'dropdown',
                          options: ['Pendiente', 'Aprobada', 'Rechazada'],
                          getValue: (o) => o?.estado ?? 'Pendiente',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: o?.idSolicitud ?? 0,
                                fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                estado: v,
                                articulo: o?.articulo ?? '',
                                cantidad: o?.cantidad ?? 0,
                                unidadMedida: o?.unidadMedida ?? '',
                                marca: o?.marca ?? '',
                                costoUnitario: o?.costoUnitario ?? 0.0,
                              ),
                        ),
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'articulo',
                          label: 'Artículo',
                          getValue: (o) => o?.articulo ?? '',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: o?.idSolicitud ?? 0,
                                fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                estado: o?.estado ?? 'Pendiente',
                                articulo: v,
                                cantidad: o?.cantidad ?? 0,
                                unidadMedida: o?.unidadMedida ?? '',
                                marca: o?.marca ?? '',
                                costoUnitario: o?.costoUnitario ?? 0.0,
                              ),
                        ),
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'cantidad',
                          label: 'Cantidad',
                          fieldType: 'number',
                          getValue: (o) => o?.cantidad.toString() ?? '0',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: o?.idSolicitud ?? 0,
                                fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                estado: o?.estado ?? 'Pendiente',
                                articulo: o?.articulo ?? '',
                                cantidad: int.tryParse(v) ?? 0,
                                unidadMedida: o?.unidadMedida ?? '',
                                marca: o?.marca ?? '',
                                costoUnitario: o?.costoUnitario ?? 0.0,
                              ),
                        ),
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'unidadMedida',
                          label: 'Unidad de Medida',
                          getValue: (o) => o?.unidadMedida ?? '',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: o?.idSolicitud ?? 0,
                                fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                estado: o?.estado ?? 'Pendiente',
                                articulo: o?.articulo ?? '',
                                cantidad: o?.cantidad ?? 0,
                                unidadMedida: v,
                                marca: o?.marca ?? '',
                                costoUnitario: o?.costoUnitario ?? 0.0,
                              ),
                        ),
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'marca',
                          label: 'Marca',
                          getValue: (o) => o?.marca ?? '',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: o?.idSolicitud ?? 0,
                                fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                estado: o?.estado ?? 'Pendiente',
                                articulo: o?.articulo ?? '',
                                cantidad: o?.cantidad ?? 0,
                                unidadMedida: o?.unidadMedida ?? '',
                                marca: v,
                                costoUnitario: o?.costoUnitario ?? 0.0,
                              ),
                        ),
                        FormFieldDefinition<PurchaseOrder>(
                          key: 'costoUnitario',
                          label: 'Costo Unitario',
                          fieldType: 'number',
                          getValue: (o) => o?.costoUnitario.toString() ?? '0.0',
                          applyValue:
                              (o, v) => PurchaseOrder(
                                numeroOrden: o?.numeroOrden ?? 0,
                                idSolicitud: o?.idSolicitud ?? 0,
                                fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                estado: o?.estado ?? 'Pendiente',
                                articulo: o?.articulo ?? '',
                                cantidad: o?.cantidad ?? 0,
                                unidadMedida: o?.unidadMedida ?? '',
                                marca: o?.marca ?? '',
                                costoUnitario: double.tryParse(v) ?? 0.0,
                              ),
                        ),
                      ],
                    ),
              ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar orden'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
        columns: [
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.05,
              child: const Text('N° Orden'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.05,
              child: const Text('ID Solicitud'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.08,
              child: const Text('Fecha'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.08,
              child: const Text('Estado'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.12,
              child: const Text('Artículo'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.05,
              child: const Text('Cantidad'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.06,
              child: const Text('Unidad'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Marca'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.08,
              child: const Text('Costo Unitario'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.05,
              child: const Text('Acciones'),
            ),
          ),
        ],
        rowBuilder: (items) {
          return items
              .map(
                (o) => DataRow(
                  cells: [
                    DataCell(Text(o.numeroOrden.toString())),
                    DataCell(Text(o.idSolicitud.toString())),
                    DataCell(
                      Text(o.fechaOrden.toIso8601String().split('T').first),
                    ),
                    DataCell(Text(o.estado)),
                    DataCell(Text(o.articulo)),
                    DataCell(Text(o.cantidad.toString())),
                    DataCell(Text(o.unidadMedida)),
                    DataCell(Text(o.marca)),
                    DataCell(Text('\$${o.costoUnitario.toStringAsFixed(2)}')),
                    DataCell(
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF10B981),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            context.read<PurchaseOrderProvider>().eliminarOrden(
                              o.numeroOrden,
                            );
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: Text('Eliminar'),
                                ),
                              ),
                            ],
                      ),
                    ),
                  ],
                ),
              )
              .toList();
        },
      ),
    );
  }
}
