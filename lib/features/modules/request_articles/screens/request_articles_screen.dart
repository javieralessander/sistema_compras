import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../../../shared/widgets/multi_article_form_field.dart';
import '../../../../shared/widgets/status_widget.dart';
import '../../article/models/article_model.dart';
import '../../article/providers/article_provider.dart';
import '../../unit/providers/unit_provider.dart';
import '../models/request_articles_model.dart';
import '../providers/request_articles_provider.dart';
import '../widgets/request_articles_detail_dialog.dart';
import '../../employee/models/employee_model.dart';
import '../../employee/providers/employee_provider.dart';
import '../../department/models/department_model.dart';

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
    final employeeOptions = context.watch<EmployeeProvider>().empleados;
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
                      dialogWidthFactor: 0.85, // 85% del ancho de pantalla
                      dialogHeightFactor: 0.85, // 85% del alto de pantalla
                      maxWidth: 1200, // Ancho máximo de 1200px
                      onSubmit: (data) async {
                        // Eliminar prints innecesarios
                        return provider.agregarSolicitud(data);
                      },
                      fromValues:
                          (values, initial) => RequestArticles(
                            empleadoSolicitante: values['empleadoSolicitante'] as Employee? ?? 
                                Employee(
                                  id: 1, 
                                  cedula: '00000000',
                                  nombre: 'Usuario Temporal', 
                                  departamento: Department(
                                    id: 1,
                                    nombre: 'Temporal',
                                    isActive: true,
                                  ),
                                  isActive: true,
                                ),
                            id: initial?.id ?? 0,
                            fechaSolicitud: DateTime.now(), // Siempre usar fecha actual
                            items: values['items'] ?? initial?.items ?? [],
                            estado: initial?.estado ?? RequestArticles.ESTADO_PENDIENTE, // Siempre pendiente para nuevas
                          ),
                      fields: [
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
                                empleadoSolicitante: r!.empleadoSolicitante,
                                fechaSolicitud: r.fechaSolicitud,
                                items: v as List<RequestArticleItem>,
                                estado: r.estado,
                              ),
                          validator:
                              (v) {
                                if (v == null || (v is List && v.isEmpty)) {
                                  return 'Debe agregar al menos un artículo';
                                }
                                if (v is List<RequestArticleItem>) {
                                  for (var item in v) {
                                    if (item.articulo.id == 0) {
                                      return 'Todos los artículos deben estar seleccionados';
                                    }
                                  }
                                }
                                return null;
                              },
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
              width: sizeScreen.width * 0.15,
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
              width: sizeScreen.width * 0.25,
              child: const Text('Artículos'),
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
              width: sizeScreen.width * 0.20,
              child: const Text('Acciones'),
            ),
          ),
        ],
        rowBuilder: (items) {
          return items.map((r) {
            // Concatenar todos los artículos de la solicitud
            final articulosTexto = r.items.isNotEmpty 
                ? r.items.map((item) => 
                    '${item.articulo.descripcion} (${item.cantidad})'
                  ).join(', ')
                : 'Sin artículos';
            
            return DataRow(
              cells: [
                DataCell(Text(r.id.toString())),
                DataCell(Text(r.empleadoSolicitante.nombre)),
                DataCell(
                  Text(r.fechaSolicitud.toIso8601String().split('T').first),
                ),
                DataCell(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Tooltip(
                      message: articulosTexto,
                      child: Text(
                        articulosTexto,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  StatusChip.request(
                    r.estado,
                    width: sizeScreen.width * 0.06,
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      // Botón para ver detalles (siempre disponible)
                      IconButton(
                        icon: Icon(
                          Icons.visibility,
                          color: AppColors.info,
                        ),
                        tooltip: 'Ver detalles',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => RequestArticlesDetailDialog(solicitud: r),
                          );
                        },
                      ),
                      
                      // PopupMenuButton con restricciones para solicitudes aprobadas
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
                                    dialogWidthFactor: 0.85, // 85% del ancho de pantalla
                                    dialogHeightFactor: 0.85, // 85% del alto de pantalla
                                    maxWidth: 1200, // Ancho máximo de 1200px
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
                                              initial?.empleadoSolicitante,
                                          fechaSolicitud:
                                              values['fechaSolicitud']
                                                  as DateTime? ??
                                              initial?.fechaSolicitud ??
                                              DateTime.now(),
                                          items:
                                              values['items'] ??
                                              initial?.items ??
                                              [],
                                          estado:
                                              values['estado'] ??
                                              initial?.estado ??
                                              RequestArticles.ESTADO_PENDIENTE,
                                        ),
                                    fields: [
                                      FormFieldDefinition<RequestArticles>(
                                        key: 'empleadoSolicitante',
                                        label: 'Empleado Solicitante',
                                        fieldType: 'dropdown',
                                        options: employeeOptions,
                                        getValue:
                                            (r) => r?.empleadoSolicitante,
                                        applyValue:
                                            (r, v) => RequestArticles(
                                              id: r?.id ?? 0,
                                              empleadoSolicitante: v,
                                              fechaSolicitud:
                                                  r?.fechaSolicitud ??
                                                  DateTime.now(),
                                              items: r?.items ?? [],
                                              estado: r?.estado ?? RequestArticles.ESTADO_PENDIENTE,
                                            ),
                                        validator:
                                            (v) =>
                                                (v == null)
                                                    ? 'Campo requerido'
                                                    : null,
                                        display: (e) => (e as Employee).nombre,
                                      ),
                                      FormFieldDefinition<RequestArticles>(
                                        key: 'fechaSolicitud',
                                        label: 'Fecha Solicitud',
                                        fieldType: 'date',
                                        getValue: (r) => r?.fechaSolicitud,
                                        applyValue:
                                            (r, v) => RequestArticles(
                                              id: r?.id ?? 0,
                                              empleadoSolicitante:
                                                  r!.empleadoSolicitante,
                                              fechaSolicitud:
                                                  v as DateTime? ??
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
                                              estado: r.estado,
                                            ),
                                        validator:
                                            (v) {
                                              if (v == null || (v is List && v.isEmpty)) {
                                                return 'Debe agregar al menos un artículo';
                                              }
                                              if (v is List<RequestArticleItem>) {
                                                for (var item in v) {
                                                  if (item.articulo.id == 0) {
                                                    return 'Todos los artículos deben estar seleccionados';
                                                  }
                                                }
                                              }
                                              return null;
                                            },
                                      ),
                                      FormFieldDefinition<RequestArticles>(
                                        key: 'estado',
                                        label: 'Estado',
                                        fieldType: 'dropdown',
                                        options: [
                                          {'value': 'PENDIENTE', 'label': 'Pendiente'},
                                          {'value': 'APROBADA', 'label': 'Aprobada'},
                                          {'value': 'RECHAZADA', 'label': 'Rechazada'},
                                        ],
                                        getValue:
                                            (r) => r?.estado.toUpperCase() ?? 'PENDIENTE',
                                        applyValue:
                                            (r, v) => RequestArticles(
                                              id: r?.id ?? 0,
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
                            // Confirmar eliminación
                            bool? confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar eliminación'),
                                content: Text('¿Está seguro de que desea eliminar la solicitud #${r.id}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmar == true) {
                              context.read<RequestProvider>().eliminarSolicitud(r.id);
                            }
                          }
                        },
                        itemBuilder: (context) {
                          List<PopupMenuEntry<String>> items = [];
                          
                          // Solo permitir editar y eliminar si NO está aprobada
                          if (r.estado.toUpperCase() != RequestArticles.ESTADO_APROBADA) {
                            items.addAll([
                              PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: Colors.blue),
                                  title: Text('Editar'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Eliminar'),
                                ),
                              ),
                            ]);
                          } else {
                            // Si está aprobada, mostrar mensaje informativo
                            items.add(
                              PopupMenuItem(
                                enabled: false,
                                child: ListTile(
                                  leading: Icon(Icons.info, color: AppColors.info),
                                  title: Text(
                                    'Solicitud aprobada\n(no editable)',
                                    style: TextStyle(
                                      color: AppColors.gray,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          return items;
                        },
                      ),
                      if (isCompras && r.estado.toUpperCase() == RequestArticles.ESTADO_PENDIENTE) ...[
                        IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          tooltip: 'Aprobar',
                          onPressed: () async {
                            try {
                              await provider.aprobarSolicitud(r.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Solicitud aprobada y orden de compra creada exitosamente'),
                                  backgroundColor: AppColors.success,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al aprobar solicitud: $e'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: AppColors.danger),
                          tooltip: 'Anular',
                          onPressed: () async {
                            try {
                              await provider.anularSolicitud(r.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Solicitud rechazada exitosamente'),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al rechazar solicitud: $e'),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
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
