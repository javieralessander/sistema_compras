import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../models/unit_model.dart';
import '../providers/unit_provider.dart';

class UnitScreen extends StatefulWidget {
  static const String name = 'units';
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnitProvider>().cargarUnidades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UnitProvider>();
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<Unit>(
        title: 'Lista de unidades de medida',
        isLoading: provider.isLoading,
        items: provider.unidades,
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
                    (_) => GenericFormDialog<Unit>(
                      title: 'Agregar Unidad de Medida',
                      onSubmit: (data) async => provider.agregarUnidad(data),
                      fromValues:
                          (values, initial) => Unit(
                            id: initial?.id ?? 0,
                            descripcion:
                                values['descripcion'] ??
                                initial?.descripcion ??
                                '',
                            isActive:
                                values['isActive'] ?? initial?.isActive ?? true,
                          ),
                      fields: [
                        FormFieldDefinition<Unit>(
                          key: 'descripcion',
                          label: 'Descripción',
                          getValue: (u) => u?.descripcion ?? '',
                          applyValue:
                              (u, v) => Unit(
                                id: u?.id ?? 0,
                                descripcion: v,
                                isActive: u?.isActive ?? true,
                              ),
                        ),
                        FormFieldDefinition<Unit>(
                          key: 'isActive',
                          label: 'Estado',
                          fieldType: 'dropdown',
                          options: [true, false],
                          getValue: (u) => u?.isActive ?? true,
                          applyValue:
                              (u, v) => Unit(
                                id: u?.id ?? 0,
                                descripcion: u?.descripcion ?? '',
                                isActive: v,
                              ),
                        ),
                      ],
                    ),
              ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar unidad'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
        columns: [
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('ID'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.25,
              child: const Text('Descripción'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.25,
              child: const Text('Estado'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.25,
              child: const Text('Acciones'),
            ),
          ),
        ],
        rowBuilder: (items) {
          return items
              .map(
                (u) => DataRow(
                  cells: [
                    DataCell(Text(u.id.toString())),
                    DataCell(Text(u.descripcion)),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color:
                                u.isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                          ),
                        ),
                        backgroundColor:
                            u.isActive
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.danger.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.04,
                          child: Text(
                            u.isActive ? 'Activo' : 'Inactivo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  u.isActive
                                      ? AppColors.success
                                      : AppColors.danger,
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
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await showDialog(
                              context: context,
                              builder:
                                  (_) => GenericFormDialog<Unit>(
                                    title: 'Editar Unidad de Medida',
                                    initialData: u,
                                    onSubmit: (data) async {
                                      await context
                                          .read<UnitProvider>()
                                          .actualizarUnidad(data);
                                    },
                                    fromValues:
                                        (values, initial) => Unit(
                                          id: initial?.id ?? 0,
                                          descripcion:
                                              values['descripcion'] ??
                                              initial?.descripcion ??
                                              '',
                                          isActive:
                                              values['isActive'] ??
                                              initial?.isActive ??
                                              true,
                                        ),
                                    fields: [
                                      FormFieldDefinition<Unit>(
                                        key: 'descripcion',
                                        label: 'Descripción',
                                        getValue: (u) => u?.descripcion ?? '',
                                        applyValue:
                                            (u, v) => Unit(
                                              id: u?.id ?? 0,
                                              descripcion: v,
                                              isActive: u?.isActive ?? true,
                                            ),
                                      ),
                                      FormFieldDefinition<Unit>(
                                        key: 'isActive',
                                        label: 'Estado',
                                        fieldType: 'dropdown',
                                        options: ['Activo', 'Inactivo'],
                                        getValue: (u) => u?.isActive ?? true,
                                        applyValue:
                                            (u, v) => Unit(
                                              id: u?.id ?? 0,
                                              descripcion: u?.descripcion ?? '',
                                              isActive: v,
                                            ),
                                      ),
                                    ],
                                  ),
                            );
                          } else if (value == 'delete') {
                            context.read<UnitProvider>().eliminarUnidad(u.id);
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
