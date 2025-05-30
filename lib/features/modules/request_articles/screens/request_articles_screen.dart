import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../models/request_articles_model.dart';
import '../providers/request_articles_provider.dart';

class RequestArticlesScreen extends StatefulWidget {
  static const String name = 'request_articles';
  const RequestArticlesScreen({super.key});

  @override
  State<RequestArticlesScreen> createState() => _RequestArticlesScreenState();
}

class _RequestArticlesScreenState extends State<RequestArticlesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RequestProvider>().cargarSolicitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<RequestArticles>(
        title: 'Solicitudes de Artículos',
        isLoading: provider.isLoading,
        items: provider.solicitudes,
        currentPage: provider.paginaActual,
        totalPages: provider.totalPaginas,
        totalItems: provider.totalRegistros,
        itemsPerPage: provider.registrosPorPagina,
        onPageChanged: provider.cambiarPagina,
        onItemsPerPageChanged: provider.cambiarRegistrosPorPagina,
        onSearch: (value) => provider.busqueda = value,
        topRightWidget: FloatingActionButton.extended(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => GenericFormDialog<RequestArticles>(
              title: 'Agregar Solicitud',
              onSubmit: (data) async => provider.agregarSolicitud(data),
              fields: [
                FormFieldDefinition<RequestArticles>(
                  key: 'empleadoSolicitante',
                  label: 'Empleado Solicitante',
                  getValue: (r) => r?.empleadoSolicitante ?? '',
                  applyValue: (r, v) => RequestArticles(
                    id: r?.id ?? 0,
                    empleadoSolicitante: v,
                    fechaSolicitud: r?.fechaSolicitud ?? DateTime.now(),
                    articulo: r?.articulo ?? '',
                    cantidad: r?.cantidad ?? 0,
                    unidadMedida: r?.unidadMedida ?? '',
                    estado: r?.estado ?? 'Pendiente',
                  ),
                ),
                FormFieldDefinition<RequestArticles>(
                  key: 'fechaSolicitud',
                  label: 'Fecha Solicitud',
                  fieldType: 'date',
                  getValue: (r) => r?.fechaSolicitud.toIso8601String().split('T').first ?? '',
                  applyValue: (r, v) => RequestArticles(
                    id: r?.id ?? 0,
                    empleadoSolicitante: r?.empleadoSolicitante ?? '',
                    fechaSolicitud: DateTime.tryParse(v) ?? DateTime.now(),
                    articulo: r?.articulo ?? '',
                    cantidad: r?.cantidad ?? 0,
                    unidadMedida: r?.unidadMedida ?? '',
                    estado: r?.estado ?? 'Pendiente',
                  ),
                ),
                FormFieldDefinition<RequestArticles>(
                  key: 'articulo',
                  label: 'Artículo',
                  getValue: (r) => r?.articulo ?? '',
                  applyValue: (r, v) => RequestArticles(
                    id: r?.id ?? 0,
                    empleadoSolicitante: r?.empleadoSolicitante ?? '',
                    fechaSolicitud: r?.fechaSolicitud ?? DateTime.now(),
                    articulo: v,
                    cantidad: r?.cantidad ?? 0,
                    unidadMedida: r?.unidadMedida ?? '',
                    estado: r?.estado ?? 'Pendiente',
                  ),
                ),
                FormFieldDefinition<RequestArticles>(
                  key: 'cantidad',
                  label: 'Cantidad',
                  fieldType: 'number',
                  getValue: (r) => r?.cantidad.toString() ?? '0',
                  applyValue: (r, v) => RequestArticles(
                    id: r?.id ?? 0,
                    empleadoSolicitante: r?.empleadoSolicitante ?? '',
                    fechaSolicitud: r?.fechaSolicitud ?? DateTime.now(),
                    articulo: r?.articulo ?? '',
                    cantidad: int.tryParse(v) ?? 0,
                    unidadMedida: r?.unidadMedida ?? '',
                    estado: r?.estado ?? 'Pendiente',
                  ),
                ),
                FormFieldDefinition<RequestArticles>(
                  key: 'unidadMedida',
                  label: 'Unidad de Medida',
                  getValue: (r) => r?.unidadMedida ?? '',
                  applyValue: (r, v) => RequestArticles(
                    id: r?.id ?? 0,
                    empleadoSolicitante: r?.empleadoSolicitante ?? '',
                    fechaSolicitud: r?.fechaSolicitud ?? DateTime.now(),
                    articulo: r?.articulo ?? '',
                    cantidad: r?.cantidad ?? 0,
                    unidadMedida: v,
                    estado: r?.estado ?? 'Pendiente',
                  ),
                ),
                FormFieldDefinition<RequestArticles>(
                  key: 'estado',
                  label: 'Estado',
                  fieldType: 'dropdown',
                  options: ['Pendiente', 'Aprobado', 'Rechazado'],
                  getValue: (r) => r?.estado ?? 'Pendiente',
                  applyValue: (r, v) => RequestArticles(
                    id: r?.id ?? 0,
                    empleadoSolicitante: r?.empleadoSolicitante ?? '',
                    fechaSolicitud: r?.fechaSolicitud ?? DateTime.now(),
                    articulo: r?.articulo ?? '',
                    cantidad: r?.cantidad ?? 0,
                    unidadMedida: r?.unidadMedida ?? '',
                    estado: v,
                  ),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar solicitud'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
        columns: [
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.05,
              child: const Text('ID'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Empleado'),
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
              child: const Text('Artículo'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Cantidad'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Unidad'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.15,
              child: const Text('Estado'),
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
          return items
              .map(
                (r) => DataRow(
                  cells: [
                    DataCell(Text(r.id.toString())),
                    DataCell(Text(r.empleadoSolicitante)),
                    DataCell(Text(
                      r.fechaSolicitud.toIso8601String().split('T').first,
                    )),
                    DataCell(Text(r.articulo)),
                    DataCell(Text(r.cantidad.toString())),
                    DataCell(Text(r.unidadMedida)),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: r.estado == 'Aprobado'
                                ? AppColors.success
                                : r.estado == 'Rechazado'
                                    ? AppColors.danger
                                    : AppColors.warning,
                          ),
                        ),
                        backgroundColor: r.estado == 'Aprobado'
                            ? AppColors.success.withOpacity(0.15)
                            : r.estado == 'Rechazado'
                                ? AppColors.danger.withOpacity(0.15)
                                : AppColors.warning.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.06,
                          child: Text(
                            r.estado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: r.estado == 'Aprobado'
                                  ? AppColors.success
                                  : r.estado == 'Rechazado'
                                      ? AppColors.danger
                                      : AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF10B981),
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            context.read<RequestProvider>().eliminarSolicitud(
                              r.id,
                            );
                          }
                        },
                        itemBuilder: (context) => [
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