import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../models/department_model.dart';
import '../providers/department_provider.dart';

class DepartmentScreen extends StatefulWidget {
  static const String name = 'departments';
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentProvider>().cargarDepartamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DepartmentProvider>();
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<Department>(
        title: 'Lista de departamentos',
        isLoading: provider.isLoading,
        items: provider.departamentos,
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
            builder: (_) => GenericFormDialog<Department>(
              title: 'Agregar Departamento',
              onSubmit: (data) async => provider.agregarDepartamento(data),
              fields: [
                FormFieldDefinition<Department>(
                  key: 'nombre',
                  label: 'Nombre',
                  getValue: (d) => d?.nombre ?? '',
                  applyValue: (d, v) => Department(
                    id: d?.id ?? 0,
                    nombre: v,
                    estado: d?.estado ?? 'Activo',
                  ),
                ),
                FormFieldDefinition<Department>(
                  key: 'estado',
                  label: 'Estado',
                  fieldType: 'dropdown',
                  options: ['Activo', 'Inactivo'],
                  getValue: (d) => d?.estado ?? 'Activo',
                  applyValue: (d, v) => Department(
                    id: d?.id ?? 0,
                    nombre: d?.nombre ?? '',
                    estado: v,
                  ),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar departamento'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
        columns: [
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.25,
              child: const Text('ID'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.25,
              child: const Text('Nombre'),
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
                (d) => DataRow(
                  cells: [
                    DataCell(Text(d.id.toString())),
                    DataCell(Text(d.nombre)),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: d.estado == 'Activo'
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        backgroundColor: d.estado == 'Activo'
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.danger.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.04,
                          child: Text(
                            d.estado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: d.estado == 'Activo'
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
                        onSelected: (value) {
                          if (value == 'delete') {
                            context.read<DepartmentProvider>().eliminarDepartamento(
                              d.id,
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