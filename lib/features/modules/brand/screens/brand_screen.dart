import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../models/brand_model.dart';
import '../providers/brand_provider.dart';

class BrandScreen extends StatefulWidget {
  static const String name = 'brands';
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandProvider>().cargarMarcas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BrandProvider>();
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<Brand>(
        title: 'Lista de marcas',
        isLoading: provider.isLoading,
        items: provider.marcas,
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
            builder: (_) => GenericFormDialog<Brand>(
              title: 'Agregar Marca',
              onSubmit: (data) async => provider.agregarMarca(data),
              fromValues: (values, initial) => Brand(
                id: initial?.id ?? 0,
                descripcion: values['descripcion'] ?? initial?.descripcion ?? '',
                estado: values['estado'] ?? initial?.estado ?? 'Activo',
              ),
              fields: [
                FormFieldDefinition<Brand>(
                  key: 'descripcion',
                  label: 'Descripción',
                  getValue: (b) => b?.descripcion ?? '',
                  applyValue: (b, v) => Brand(
                    id: b?.id ?? 0,
                    descripcion: v,
                    estado: b?.estado ?? 'Activo',
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                ),
                FormFieldDefinition<Brand>(
                  key: 'estado',
                  label: 'Estado',
                  fieldType: 'dropdown',
                  options: ['Activo', 'Inactivo'],
                  getValue: (b) => b?.estado ?? 'Activo',
                  applyValue: (b, v) => Brand(
                    id: b?.id ?? 0,
                    descripcion: b?.descripcion ?? '',
                    estado: v,
                  ),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar marca'),
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
                (b) => DataRow(
                  cells: [
                    DataCell(Text(b.id.toString())),
                    DataCell(Text(b.descripcion)),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: b.estado == 'Activo'
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        backgroundColor: b.estado == 'Activo'
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.danger.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.04,
                          child: Text(
                            b.estado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: b.estado == 'Activo'
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
                              builder: (_) => GenericFormDialog<Brand>(
                                title: 'Editar Marca',
                                initialData: b,
                                onSubmit: (data) async {
                                  await context.read<BrandProvider>().actualizarMarca(data);
                                },
                                fromValues: (values, initial) => Brand(
                                  id: initial?.id ?? 0,
                                  descripcion: values['descripcion'] ?? initial?.descripcion ?? '',
                                  estado: values['estado'] ?? initial?.estado ?? 'Activo',
                                ),
                                fields: [
                                  FormFieldDefinition<Brand>(
                                    key: 'descripcion',
                                    label: 'Descripción',
                                    getValue: (b) => b?.descripcion ?? '',
                                    applyValue: (b, v) => Brand(
                                      id: b?.id ?? 0,
                                      descripcion: v,
                                      estado: b?.estado ?? 'Activo',
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
                                  ),
                                  FormFieldDefinition<Brand>(
                                    key: 'estado',
                                    label: 'Estado',
                                    fieldType: 'dropdown',
                                    options: ['Activo', 'Inactivo'],
                                    getValue: (b) => b?.estado ?? 'Activo',
                                    applyValue: (b, v) => Brand(
                                      id: b?.id ?? 0,
                                      descripcion: b?.descripcion ?? '',
                                      estado: v,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (value == 'delete') {
                            context.read<BrandProvider>().eliminarMarca(b.id);
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
                ),
              )
              .toList();
        },
      ),
    );
  }
}