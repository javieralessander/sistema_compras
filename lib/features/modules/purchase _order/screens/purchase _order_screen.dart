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
          return items.map((o) {
            final item = o.items.isNotEmpty ? o.items.first : null;
            return DataRow(
              cells: [
                DataCell(Text(o.numeroOrden.toString())),
                DataCell(Text(o.idSolicitud.toString())),
                DataCell(Text(o.fechaOrden.toIso8601String().split('T').first)),
                DataCell(Text(o.estado)),
                DataCell(Text(item?.articulo ?? '')),
                DataCell(Text(item?.cantidad.toString() ?? '')),
                DataCell(Text(item?.unidadMedida ?? '')),
                DataCell(Text(item?.marca ?? '')),
                DataCell(Text(item != null ? '\$${item.costoUnitario.toStringAsFixed(2)}' : '')),
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF10B981)),
                    onSelected: (value) async {
                      if (value == 'edit') {
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
                                estado: values['estado'] ?? initial?.estado ?? 'Pendiente',
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
                                fieldType: 'number',
                                getValue: (o) => o?.idSolicitud.toString() ?? '',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: int.tryParse(v) ?? 0,
                                    fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                    estado: o?.estado ?? 'Pendiente',
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: item?.articulo ?? '',
                                        cantidad: item?.cantidad ?? 0,
                                        unidadMedida: item?.unidadMedida ?? '',
                                        marca: item?.marca ?? '',
                                        costoUnitario: item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              FormFieldDefinition<PurchaseOrder>(
                                key: 'fechaOrden',
                                label: 'Fecha Orden',
                                fieldType: 'date',
                                getValue: (o) => o?.fechaOrden.toIso8601String().split('T').first ?? '',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: o?.idSolicitud ?? 0,
                                    fechaOrden: DateTime.tryParse(v) ?? DateTime.now(),
                                    estado: o?.estado ?? 'Pendiente',
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: item?.articulo ?? '',
                                        cantidad: item?.cantidad ?? 0,
                                        unidadMedida: item?.unidadMedida ?? '',
                                        marca: item?.marca ?? '',
                                        costoUnitario: item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              FormFieldDefinition<PurchaseOrder>(
                                key: 'estado',
                                label: 'Estado',
                                fieldType: 'dropdown',
                                options: ['Pendiente', 'Aprobada', 'Rechazada'],
                                getValue: (o) => o?.estado ?? 'Pendiente',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: o?.idSolicitud ?? 0,
                                    fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                    estado: v,
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: item?.articulo ?? '',
                                        cantidad: item?.cantidad ?? 0,
                                        unidadMedida: item?.unidadMedida ?? '',
                                        marca: item?.marca ?? '',
                                        costoUnitario: item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              FormFieldDefinition<PurchaseOrder>(
                                key: 'articulo',
                                label: 'Artículo',
                                getValue: (o) => o?.items.isNotEmpty == true ? o!.items.first.articulo : '',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: o?.idSolicitud ?? 0,
                                    fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                    estado: o?.estado ?? 'Pendiente',
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: v,
                                        cantidad: item?.cantidad ?? 0,
                                        unidadMedida: item?.unidadMedida ?? '',
                                        marca: item?.marca ?? '',
                                        costoUnitario: item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              FormFieldDefinition<PurchaseOrder>(
                                key: 'cantidad',
                                label: 'Cantidad',
                                fieldType: 'number',
                                getValue: (o) => o?.items.isNotEmpty == true ? o!.items.first.cantidad.toString() : '0',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: o?.idSolicitud ?? 0,
                                    fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                    estado: o?.estado ?? 'Pendiente',
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: item?.articulo ?? '',
                                        cantidad: int.tryParse(v) ?? 0,
                                        unidadMedida: item?.unidadMedida ?? '',
                                        marca: item?.marca ?? '',
                                        costoUnitario: item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              FormFieldDefinition<PurchaseOrder>(
                                key: 'unidadMedida',
                                label: 'Unidad de Medida',
                                getValue: (o) => o?.items.isNotEmpty == true ? o!.items.first.unidadMedida : '',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: o?.idSolicitud ?? 0,
                                    fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                    estado: o?.estado ?? 'Pendiente',
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: item?.articulo ?? '',
                                        cantidad: item?.cantidad ?? 0,
                                        unidadMedida: v,
                                        marca: item?.marca ?? '',
                                        costoUnitario: item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              FormFieldDefinition<PurchaseOrder>(
                                key: 'marca',
                                label: 'Marca',
                                getValue: (o) => o?.items.isNotEmpty == true ? o!.items.first.marca : '',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: o?.idSolicitud ?? 0,
                                    fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                    estado: o?.estado ?? 'Pendiente',
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: item?.articulo ?? '',
                                        cantidad: item?.cantidad ?? 0,
                                        unidadMedida: item?.unidadMedida ?? '',
                                        marca: v,
                                        costoUnitario: item?.costoUnitario ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                              FormFieldDefinition<PurchaseOrder>(
                                key: 'costoUnitario',
                                label: 'Costo Unitario',
                                fieldType: 'number',
                                getValue: (o) => o?.items.isNotEmpty == true ? o!.items.first.costoUnitario.toString() : '0.0',
                                applyValue: (o, v) {
                                  final item = o?.items.isNotEmpty == true ? o!.items.first : null;
                                  return PurchaseOrder(
                                    numeroOrden: o?.numeroOrden ?? 0,
                                    idSolicitud: o?.idSolicitud ?? 0,
                                    fechaOrden: o?.fechaOrden ?? DateTime.now(),
                                    estado: o?.estado ?? 'Pendiente',
                                    items: [
                                      PurchaseOrderItem(
                                        articulo: item?.articulo ?? '',
                                        cantidad: item?.cantidad ?? 0,
                                        unidadMedida: item?.unidadMedida ?? '',
                                        marca: item?.marca ?? '',
                                        costoUnitario: double.tryParse(v) ?? 0.0,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      } else if (value == 'delete') {
                        context.read<PurchaseOrderProvider>().eliminarOrden(o.numeroOrden);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: Colors.blue),
                          title: Text('Editar'),
                        ),
                      ),
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
            );
          }).toList();
        },
      ),
    );
  }
}