import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/widgets/multi_article_form_field.dart';
import '../../article/models/article_model.dart';
import '../../article/providers/article_provider.dart';
import '../../unit/providers/unit_provider.dart';
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
    final articleOptions = context.watch<ArticleProvider>().articulos;
    final unitOptions = context.watch<UnitProvider>().unidades;
    //  final isCompras = context.watch<UserProvider>().isCompras;
    final isCompras = true;

    List<RequestArticleItem> mapInitialItemsToOptions(
      List<RequestArticleItem> initialItems,
      List<Article> articleOptions,
    ) {
      return initialItems.map((item) {
        final matchedArticle = articleOptions.firstWhere(
          (a) => a.id == item.articulo.id,
          orElse: () => item.articulo,
        );
        return item.copyWith(articulo: matchedArticle);
      }).toList();
    }

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
          onPressed:
              () => showDialog(
                context: context,
                builder:
                    (_) => GenericFormDialog<RequestArticles>(
                      title: 'Agregar Solicitud',
                      onSubmit: (data) async => provider.agregarSolicitud(data),
                      fromValues:
                          (values, initial) => RequestArticles(
                            id: initial?.id ?? 0,
                            empleadoId:
                                values['empleadoId'] ??
                                initial?.empleadoId ??
                                0,
                            empleadoSolicitante:
                                values['empleadoSolicitante'] ??
                                initial?.empleadoSolicitante ??
                                '',
                            fechaSolicitud:
                                DateTime.tryParse(
                                  values['fechaSolicitud'] ?? '',
                                ) ??
                                initial?.fechaSolicitud ??
                                DateTime.now(),
                            items: values['items'] ?? initial?.items ?? [],
                            estado:
                                values['estado'] ??
                                initial?.estado ??
                                'Pendiente',
                          ),
                      fields: [
                        FormFieldDefinition<RequestArticles>(
                          key: 'empleadoSolicitante',
                          label: 'Empleado Solicitante',
                          getValue: (r) => r?.empleadoSolicitante ?? '',
                          applyValue:
                              (r, v) => RequestArticles(
                                id: r?.id ?? 0,
                                empleadoId: r?.empleadoId ?? 0,
                                empleadoSolicitante: v,
                                fechaSolicitud:
                                    r?.fechaSolicitud ?? DateTime.now(),
                                items: r?.items ?? [],
                                estado: r?.estado ?? 'Pendiente',
                              ),
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Campo requerido'
                                      : null,
                        ),
                        FormFieldDefinition<RequestArticles>(
                          key: 'fechaSolicitud',
                          label: 'Fecha Solicitud',
                          fieldType: 'date',
                          getValue:
                              (r) =>
                                  r?.fechaSolicitud
                                      .toIso8601String()
                                      .split('T')
                                      .first ??
                                  '',
                          applyValue:
                              (r, v) => RequestArticles(
                                id: r?.id ?? 0,
                                empleadoId: r?.empleadoId ?? 0,
                                empleadoSolicitante: r!.empleadoSolicitante,
                                fechaSolicitud:
                                    DateTime.tryParse(v) ?? DateTime.now(),
                                items: r.items,
                                estado: r.estado,
                              ),
                        ),
                        // Campo personalizado para varios artículos
                        FormFieldDefinition<RequestArticles>(
                          key: 'items',
                          label: 'Artículos solicitados',
                          fieldType: 'custom',
                          builder: (context, controller, initial) {
                            return MultiArticleFormField(
                              initialItems: initial?.items ?? [],
                              articleOptions: articleOptions,
                              unitOptions: unitOptions,
                              onChanged: (items) {
                                controller.setValue(items);
                              },
                            );
                          },
                          getValue: (r) => r?.items ?? [],
                          applyValue:
                              (r, v) => RequestArticles(
                                id: r?.id ?? 0,
                                empleadoId: r?.empleadoId ?? 0,
                                empleadoSolicitante: r!.empleadoSolicitante,
                                fechaSolicitud: r.fechaSolicitud,
                                items: v as List<RequestArticleItem>,
                                estado: r.estado,
                              ),
                          validator:
                              (v) =>
                                  (v == null || (v is List && v.isEmpty))
                                      ? 'Debe agregar al menos un artículo'
                                      : null,
                        ),
                        FormFieldDefinition<RequestArticles>(
                          key: 'estado',
                          label: 'Estado',
                          fieldType: 'dropdown',
                          options: ['Pendiente', 'Aprobado', 'Rechazado'],
                          getValue: (r) => r?.estado ?? 'Pendiente',
                          applyValue:
                              (r, v) => RequestArticles(
                                id: r?.id ?? 0,
                                empleadoId: r?.empleadoId ?? 0,
                                empleadoSolicitante: r!.empleadoSolicitante,
                                fechaSolicitud: r.fechaSolicitud,
                                items: r.items,
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
              width: sizeScreen.width * 0.10,
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
          return items.map((r) {
            final firstItem = r.items.isNotEmpty ? r.items.first : null;
            return DataRow(
              cells: [
                DataCell(Text(r.id.toString())),
                DataCell(Text(r.empleadoSolicitante.nombre)),
                DataCell(
                  Text(r.fechaSolicitud.toIso8601String().split('T').first),
                ),
                DataCell(Text(firstItem?.articulo.descripcion ?? '')),
                DataCell(Text(firstItem?.cantidad.toString() ?? '')),
                DataCell(Text(firstItem?.unidadMedida.descripcion ?? '')),
                DataCell(
                  Chip(
                    shape: StadiumBorder(
                      side: BorderSide(
                        color:
                            r.estado == 'Aprobado'
                                ? AppColors.success
                                : r.estado == 'Rechazado'
                                ? AppColors.danger
                                : AppColors.warning,
                      ),
                    ),
                    backgroundColor:
                        r.estado == 'Aprobado'
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
                          color:
                              r.estado == 'Aprobado'
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
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF10B981),
                        ),
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await showDialog(
                              context: context,
                              builder:
                                  (_) => GenericFormDialog<RequestArticles>(
                                    title: 'Editar Solicitud',
                                    initialData: r,
                                    onSubmit: (data) async {
                                      await context
                                          .read<RequestProvider>()
                                          .actualizarSolicitud(data);
                                    },
                                    fromValues:
                                        (values, initial) => RequestArticles(
                                          id: initial?.id ?? 0,
                                          empleadoSolicitante:
                                              values['empleadoSolicitante'] ??
                                              initial?.empleadoSolicitante ??
                                              '',
                                          fechaSolicitud:
                                              DateTime.tryParse(
                                                values['fechaSolicitud'] ?? '',
                                              ) ??
                                              initial?.fechaSolicitud ??
                                              DateTime.now(),
                                          items:
                                              values['items'] ??
                                              initial?.items ??
                                              [],
                                          estado:
                                              values['estado'] ??
                                              initial?.estado ??
                                              'Pendiente',
                                          empleadoId: initial?.empleadoId ?? 0,
                                        ),
                                    fields: [
                                      FormFieldDefinition<RequestArticles>(
                                        key: 'empleadoSolicitante',
                                        label: 'Empleado Solicitante',
                                        getValue:
                                            (r) => r?.empleadoSolicitante ?? '',
                                        applyValue:
                                            (r, v) => RequestArticles(
                                              id: r?.id ?? 0,
                                              empleadoId: r?.empleadoId ?? 0,
                                              empleadoSolicitante: v,
                                              fechaSolicitud:
                                                  r?.fechaSolicitud ??
                                                  DateTime.now(),
                                              items: r?.items ?? [],
                                              estado: r?.estado ?? 'Pendiente',
                                            ),
                                        validator:
                                            (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Campo requerido'
                                                    : null,
                                      ),
                                      FormFieldDefinition<RequestArticles>(
                                        key: 'fechaSolicitud',
                                        label: 'Fecha Solicitud',
                                        fieldType: 'date',
                                        getValue:
                                            (r) =>
                                                r?.fechaSolicitud
                                                    .toIso8601String()
                                                    .split('T')
                                                    .first ??
                                                '',
                                        applyValue:
                                            (r, v) => RequestArticles(
                                              id: r?.id ?? 0,
                                              empleadoId: r?.empleadoId ?? 0,
                                              empleadoSolicitante:
                                                  r!.empleadoSolicitante,
                                              fechaSolicitud:
                                                  DateTime.tryParse(v) ??
                                                  DateTime.now(),
                                              items: r.items,
                                              estado: r.estado,
                                            ),
                                      ),
                                      FormFieldDefinition<RequestArticles>(
                                        key: 'items',
                                        label: 'Artículos solicitados',
                                        fieldType: 'custom',
                                        builder: (
                                          context,
                                          controller,
                                          initial,
                                        ) {
                                          final initialItems =
                                              mapInitialItemsToOptions(
                                                initial?.items ?? [],
                                                articleOptions,
                                              );
                                          return MultiArticleFormField(
                                            initialItems: initialItems,
                                            articleOptions: articleOptions,
                                            unitOptions: unitOptions,
                                            onChanged: (items) {
                                              controller.setValue(items);
                                            },
                                          );
                                        },
                                        getValue: (r) => r?.items ?? [],
                                        applyValue:
                                            (r, v) => RequestArticles(
                                              id: r?.id ?? 0,
                                              empleadoId: r?.empleadoId ?? 0,
                                              empleadoSolicitante:
                                                  r!.empleadoSolicitante,
                                              fechaSolicitud: r.fechaSolicitud,
                                              items:
                                                  v is List<RequestArticleItem>
                                                      ? v
                                                      : (v is List
                                                          ? v
                                                              .cast<
                                                                RequestArticleItem
                                                              >()
                                                          : <
                                                            RequestArticleItem
                                                          >[]),
                                              estado: r?.estado ?? 'Pendiente',
                                            ),
                                        validator:
                                            (v) =>
                                                (v == null ||
                                                        (v is List &&
                                                            v.isEmpty))
                                                    ? 'Debe agregar al menos un artículo'
                                                    : null,
                                      ),
                                      FormFieldDefinition<RequestArticles>(
                                        key: 'estado',
                                        label: 'Estado',
                                        fieldType: 'dropdown',
                                        options: [
                                          'Pendiente',
                                          'Aprobado',
                                          'Rechazado',
                                        ],
                                        getValue:
                                            (r) => r?.estado ?? 'Pendiente',
                                        applyValue:
                                            (r, v) => RequestArticles(
                                              id: r?.id ?? 0,
                                              empleadoId: r?.empleadoId ?? 0,
                                              empleadoSolicitante:
                                                  r!.empleadoSolicitante,
                                              fechaSolicitud: r.fechaSolicitud,
                                              items: r.items,
                                              estado: v,
                                            ),
                                      ),
                                    ],
                                  ),
                            );
                          } else if (value == 'delete') {
                            context.read<RequestProvider>().eliminarSolicitud(
                              r.id,
                            );
                          }
                        },
                        itemBuilder:
                            (context) => [
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
                      if (isCompras && r.estado == 'Pendiente') ...[
                        IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          tooltip: 'Aprobar',
                          onPressed: () async {
                            await provider.aprobarSolicitud(r.id);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: AppColors.danger),
                          tooltip: 'Anular',
                          onPressed: () async {
                            await provider.anularSolicitud(r.id);
                          },
                        ),
                      ],
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
