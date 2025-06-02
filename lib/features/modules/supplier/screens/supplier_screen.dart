import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../models/supplier_model.dart';
import '../providers/supplier_provider.dart';

class SupplierScreen extends StatefulWidget {
  static const String name = 'suppliers';
  const SupplierScreen({super.key});

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().cargarProveedores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<Supplier>(
        title: 'Lista de proveedores',
        isLoading: provider.isLoading,
        items: provider.proveedores,
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
            builder: (_) => GenericFormDialog<Supplier>(
              title: 'Agregar Proveedor',
              onSubmit: (data) async => provider.agregarProveedor(data),
              fromValues: (values, initial) => Supplier(
                id: initial?.id ?? 0,
                cedulaRnc: values['cedulaRnc'] ?? initial?.cedulaRnc ?? '',
                nombreComercial: values['nombreComercial'] ?? initial?.nombreComercial ?? '',
                estado: values['estado'] ?? initial?.estado ?? 'Activo',
              ),
              fields: [
                FormFieldDefinition<Supplier>(
                  key: 'cedulaRnc',
                  label: 'Cédula / RNC',
                  getValue: (s) => s?.cedulaRnc ?? '',
                  applyValue: (s, v) => Supplier(
                    id: s?.id ?? 0,
                    cedulaRnc: v,
                    nombreComercial: s?.nombreComercial ?? '',
                    estado: s?.estado ?? 'Activo',
                  ),
                ),
                FormFieldDefinition<Supplier>(
                  key: 'nombreComercial',
                  label: 'Nombre Comercial',
                  getValue: (s) => s?.nombreComercial ?? '',
                  applyValue: (s, v) => Supplier(
                    id: s?.id ?? 0,
                    cedulaRnc: s?.cedulaRnc ?? '',
                    nombreComercial: v,
                    estado: s?.estado ?? 'Activo',
                  ),
                ),
                FormFieldDefinition<Supplier>(
                  key: 'estado',
                  label: 'Estado',
                  fieldType: 'dropdown',
                  options: ['Activo', 'Inactivo'],
                  getValue: (s) => s?.estado ?? 'Activo',
                  applyValue: (s, v) => Supplier(
                    id: s?.id ?? 0,
                    cedulaRnc: s?.cedulaRnc ?? '',
                    nombreComercial: s?.nombreComercial ?? '',
                    estado: v,
                  ),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar proveedor'),
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
              width: sizeScreen.width * 0.20,
              child: const Text('Cédula / RNC'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.20,
              child: const Text('Nombre Comercial'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.20,
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
          return items
              .map(
                (s) => DataRow(
                  cells: [
                    DataCell(Text(s.id.toString())),
                    DataCell(Text(s.cedulaRnc)),
                    DataCell(Text(s.nombreComercial)),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: s.estado == 'Activo'
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        backgroundColor: s.estado == 'Activo'
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.danger.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.06,
                          child: Text(
                            s.estado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: s.estado == 'Activo'
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
                              builder: (_) => GenericFormDialog<Supplier>(
                                title: 'Editar Proveedor',
                                initialData: s,
                                onSubmit: (data) async {
                                  await context.read<SupplierProvider>().actualizarProveedor(data);
                                },
                                fromValues: (values, initial) => Supplier(
                                  id: initial?.id ?? 0,
                                  cedulaRnc: values['cedulaRnc'] ?? initial?.cedulaRnc ?? '',
                                  nombreComercial: values['nombreComercial'] ?? initial?.nombreComercial ?? '',
                                  estado: values['estado'] ?? initial?.estado ?? 'Activo',
                                ),
                                fields: [
                                  FormFieldDefinition<Supplier>(
                                    key: 'cedulaRnc',
                                    label: 'Cédula / RNC',
                                    getValue: (s) => s?.cedulaRnc ?? '',
                                    applyValue: (s, v) => Supplier(
                                      id: s?.id ?? 0,
                                      cedulaRnc: v,
                                      nombreComercial: s?.nombreComercial ?? '',
                                      estado: s?.estado ?? 'Activo',
                                    ),
                                  ),
                                  FormFieldDefinition<Supplier>(
                                    key: 'nombreComercial',
                                    label: 'Nombre Comercial',
                                    getValue: (s) => s?.nombreComercial ?? '',
                                    applyValue: (s, v) => Supplier(
                                      id: s?.id ?? 0,
                                      cedulaRnc: s?.cedulaRnc ?? '',
                                      nombreComercial: v,
                                      estado: s?.estado ?? 'Activo',
                                    ),
                                  ),
                                  FormFieldDefinition<Supplier>(
                                    key: 'estado',
                                    label: 'Estado',
                                    fieldType: 'dropdown',
                                    options: ['Activo', 'Inactivo'],
                                    getValue: (s) => s?.estado ?? 'Activo',
                                    applyValue: (s, v) => Supplier(
                                      id: s?.id ?? 0,
                                      cedulaRnc: s?.cedulaRnc ?? '',
                                      nombreComercial: s?.nombreComercial ?? '',
                                      estado: v,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (value == 'delete') {
                            context.read<SupplierProvider>().eliminarProveedor(s.id);
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