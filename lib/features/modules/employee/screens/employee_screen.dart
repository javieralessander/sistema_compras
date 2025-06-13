import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_compras/features/modules/department/providers/department_provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../department/models/department_model.dart';
import '../models/employee_model.dart';
import '../providers/employee_provider.dart';

class EmployeeScreen extends StatefulWidget {
  static const String name = 'employee-screen';
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar empleados solo una vez al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().cargarEmpleados();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final departments = context.watch<DepartmentProvider>().departamentos;
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<Employee>(
        title: 'Lista de empleados',
        isLoading: provider.isLoading,
        items: provider.empleados,
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
                    (_) => GenericFormDialog<Employee>(
                      title: 'Agregar Empleado',
                      onSubmit: (data) async => provider.agregarEmpleado(data),
                      fromValues: (values, initial) {
                        final matchedDepartment = departments.firstWhere(
                          (d) =>
                              d.id ==
                              (values['departamento']?.id ??
                                  initial?.departamento?.id),
                          orElse:
                              () =>
                                  values['departamento'] ??
                                  initial?.departamento,
                        );
                        return Employee(
                          id: initial?.id ?? 0,
                          cedula: values['cedula'] ?? initial?.cedula ?? '',
                          nombre: values['nombre'] ?? initial?.nombre ?? '',
                          departamento: matchedDepartment,
                          isActive:
                                values['isActive'] ?? initial?.isActive ?? true,
                        );
                      },
                      fields: [
                        FormFieldDefinition<Employee>(
                          key: 'cedula',
                          label: 'Cédula',
                          getValue: (e) => e?.cedula ?? '',
                          applyValue:
                              (e, v) => Employee(
                                id: e?.id ?? 0,
                                cedula: v,
                                nombre: e!.nombre,
                                departamento: e.departamento,
                                isActive: e.isActive,
                              ),
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Campo requerido'
                                      : null,
                        ),
                        FormFieldDefinition<Employee>(
                          key: 'nombre',
                          label: 'Nombre',
                          getValue: (e) => e?.nombre ?? '',
                          applyValue:
                              (e, v) => Employee(
                                id: e?.id ?? 0,
                                cedula: e?.cedula ?? '',
                                nombre: v,
                                departamento: e!.departamento,
                                isActive: e.isActive,
                              ),
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Campo requerido'
                                      : null,
                        ),
                        FormFieldDefinition<Employee>(
                          key: 'departamento',
                          label: 'Departamento',
                          fieldType: 'dropdown',
                          options: departments,
                          getValue: (e) => e?.departamento,
                          applyValue:
                              (e, v) => Employee(
                                id: e?.id ?? 0,
                                cedula: e?.cedula ?? '',
                                nombre: e?.nombre ?? '',
                                departamento: v as Department,
                                isActive: e?.isActive ?? true,
                              ),
                          validator:
                              (v) => v == null ? 'Campo requerido' : null,
                          display: (d) => (d as Department).nombre,
                        ),
                        FormFieldDefinition<Employee>(
                          key: 'estado',
                          label: 'Estado',
                          fieldType: 'dropdown',
                          options: ['Activo', 'Inactivo'],
                          getValue: (e) => e?.isActive ?? 'Activo',
                          applyValue:
                              (e, v) => Employee(
                                id: e?.id ?? 0,
                                cedula: e?.cedula ?? '',
                                nombre: e?.nombre ?? '',
                                departamento: e!.departamento,
                                isActive: v,
                              ),
                        ),
                      ],
                    ),
              ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar empleado'),
          backgroundColor: AppColors.success,
          foregroundColor: AppColors.white,
        ),
        columns: [
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.08,
              child: const Text('ID'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.16,
              child: const Text('Cédula'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.16,
              child: const Text('Nombre'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.16,
              child: const Text('Departamento'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.16,
              child: const Text('Estado'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.14,
              child: const Text('Acciones'),
            ),
          ),
        ],
        rowBuilder: (items) {
          return items
              .map(
                (e) => DataRow(
                  cells: [
                    DataCell(Text(e.id.toString())),
                    DataCell(Text(e.cedula)),
                    DataCell(Text(e.nombre)),
                    DataCell(Text(e.departamento.nombre)),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color:
                                e.isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                          ),
                        ),
                        backgroundColor:
                            e.isActive
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.danger.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.04,
                          child: Text(
                            e.isActive ? 'Activo' : 'Inactivo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  e.isActive
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
                                  (_) => GenericFormDialog<Employee>(
                                    title: 'Editar Empleado',
                                    initialData: e,
                                    onSubmit: (data) async {
                                      await context
                                          .read<EmployeeProvider>()
                                          .actualizarEmpleado(data);
                                    },
                                    fromValues: (values, initial) {
                                      final matchedDepartment = departments
                                          .firstWhere(
                                            (d) =>
                                                d.id ==
                                                (values['departamento']?.id ??
                                                    initial?.departamento?.id),
                                            orElse:
                                                () =>
                                                    values['departamento'] ??
                                                    initial?.departamento,
                                          );
                                      return Employee(
                                        id: initial?.id ?? 0,
                                        cedula:
                                            values['cedula'] ??
                                            initial?.cedula ??
                                            '',
                                        nombre:
                                            values['nombre'] ??
                                            initial?.nombre ??
                                            '',
                                        departamento: matchedDepartment,
                                        isActive:
                                            values['isActive'] ??
                                            initial?.isActive ??
                                            true,
                                      );
                                    },
                                    fields: [
                                      FormFieldDefinition<Employee>(
                                        key: 'cedula',
                                        label: 'Cédula',
                                        getValue: (e) => e?.cedula ?? '',
                                        applyValue:
                                            (e, v) => Employee(
                                              id: e?.id ?? 0,
                                              cedula: v,
                                              nombre: e?.nombre ?? '',
                                              departamento: e!.departamento,
                                              isActive: e.isActive,
                                            ),
                                        validator:
                                            (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Campo requerido'
                                                    : null,
                                      ),
                                      FormFieldDefinition<Employee>(
                                        key: 'nombre',
                                        label: 'Nombre',
                                        getValue: (e) => e?.nombre ?? '',
                                        applyValue:
                                            (e, v) => Employee(
                                              id: e?.id ?? 0,
                                              cedula: e?.cedula ?? '',
                                              nombre: v,
                                              departamento: e!.departamento,
                                              isActive: e.isActive,
                                            ),
                                        validator:
                                            (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Campo requerido'
                                                    : null,
                                      ),
                                      FormFieldDefinition<Employee>(
                                        key: 'departamento',
                                        label: 'Departamento',
                                        fieldType: 'dropdown',
                                        options: departments,
                                        getValue: (e) => e?.departamento,
                                        applyValue:
                                            (e, v) => Employee(
                                              id: e?.id ?? 0,
                                              cedula: e?.cedula ?? '',
                                              nombre: e?.nombre ?? '',
                                              departamento: v as Department,
                                              isActive: e?.isActive ?? true,
                                            ),
                                        validator:
                                            (v) =>
                                                v == null
                                                    ? 'Campo requerido'
                                                    : null,
                                        display: (d) => d.nombre,
                                      ),
                                      FormFieldDefinition<Employee>(
                                        key: 'isActive',
                                        label: 'Estado',
                                        fieldType: 'dropdown',
                                        options: [true, false],
                                        getValue:
                                            (e) => e?.isActive ?? true,
                                        applyValue:
                                            (e, v) => Employee(
                                              id: e?.id ?? 0,
                                              cedula: e?.cedula ?? '',
                                              nombre: e?.nombre ?? '',
                                              departamento: e!.departamento,
                                              isActive: v,
                                            ),
                                      ),
                                    ],
                                  ),
                            );
                          } else if (value == 'delete') {
                            context.read<EmployeeProvider>().eliminarEmpleado(
                              e.id,
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
