import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_compras/features/modules/brand/providers/brand_provider.dart';
import 'package:sistema_compras/features/modules/unit/providers/unit_provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
import '../../brand/models/brand_model.dart';
import '../../unit/models/unit_model.dart';
import '../models/article_model.dart';
import '../providers/article_provider.dart';

class ArticleScreen extends StatefulWidget {
  static const String name = 'articles';
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleProvider>().cargarArticulos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ArticleProvider>();
    final brandOptions = context.watch<BrandProvider>().marcas;
    final unitOptions = context.watch<UnitProvider>().unidades;
    final sizeScreen = MediaQuery.of(context).size;
    final isMobile = sizeScreen.width < 800;

    return Scaffold(
      drawer: isMobile ? const CustomDrawer() : null,
      appBar: GenericAppBar(isMobile: isMobile),
      body: GenericDataTable<Article>(
        title: 'Lista de artículos',
        isLoading: provider.isLoading,
        items: provider.articulos,
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
                    (_) => GenericFormDialog<Article>(
                      title: 'Agregar Artículo',
                      onSubmit: (data) async => provider.agregarArticulo(data),
                      fromValues:
                          (values, initial) => Article(
                            id: initial?.id ?? 0,
                            descripcion:
                                values['descripcion'] ??
                                initial?.descripcion ??
                                '',
                            marca: values['marca'] ?? initial?.marca,
                            unidadMedida:
                                values['unidadMedida'] ?? initial?.unidadMedida,
                            existencia:
                                int.tryParse(
                                  values['existencia']?.toString() ?? '',
                                ) ??
                                initial?.existencia ??
                                0,
                            isActive:
                                values['isActive'] ?? initial?.isActive ?? true,
                          ),
                      fields: [
                        FormFieldDefinition<Article>(
                          key: 'descripcion',
                          label: 'Descripción',
                          getValue: (a) => a?.descripcion ?? '',
                          applyValue:
                              (a, v) => Article(
                                id: a?.id ?? 0,
                                descripcion: v,
                                marca: a!.marca,
                                unidadMedida: a.unidadMedida,
                                existencia: a.existencia,
                                isActive: a.isActive,
                              ),
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? 'Campo requerido'
                                      : null,
                        ),
                        FormFieldDefinition<Article>(
                          key: 'marca',
                          label: 'Marca',
                          fieldType: 'dropdown',
                          options: brandOptions,
                          getValue: (a) => a?.marca,
                          applyValue:
                              (a, v) => Article(
                                id: a?.id ?? 0,
                                descripcion: a?.descripcion ?? '',
                                marca: v as Brand,
                                unidadMedida: a!.unidadMedida,
                                existencia: a.existencia,
                                isActive: a.isActive,
                              ),
                          display: (b) => (b as Brand).descripcion,
                          validator:
                              (v) => v == null ? 'Campo requerido' : null,
                        ),
                        FormFieldDefinition<Article>(
                          key: 'unidadMedida',
                          label: 'Unidad de Medida',
                          fieldType: 'dropdown',
                          options: unitOptions,
                          getValue: (a) => a?.unidadMedida,
                          applyValue:
                              (a, v) => Article(
                                id: a?.id ?? 0,
                                descripcion: a?.descripcion ?? '',
                                marca: a!.marca,
                                unidadMedida: v as Unit,
                                existencia: a.existencia,
                                isActive: a.isActive,
                              ),
                          display: (u) => (u as Unit).descripcion,
                          validator:
                              (v) => v == null ? 'Campo requerido' : null,
                        ),
                        FormFieldDefinition<Article>(
                          key: 'existencia',
                          label: 'Existencia',
                          fieldType: 'number',
                          getValue: (a) => a?.existencia.toString() ?? '0',
                          applyValue:
                              (a, v) => Article(
                                id: a?.id ?? 0,
                                descripcion: a?.descripcion ?? '',
                                marca: a!.marca,
                                unidadMedida: a.unidadMedida,
                                existencia: int.tryParse(v.toString()) ?? 0,
                                isActive: a.isActive,
                              ),
                          validator:
                              (v) =>
                                  (v == null || v.toString().isEmpty)
                                      ? 'Campo requerido'
                                      : null,
                        ),
                        FormFieldDefinition<Article>(
                          key: 'isActive',
                          label: 'isActive',
                          fieldType: 'dropdown',
                          options: [true, false],
                          getValue: (a) => a?.isActive ?? true,
                          applyValue:
                              (a, v) => Article(
                                id: a?.id ?? 0,
                                descripcion: a?.descripcion ?? '',
                                marca: a!.marca,
                                unidadMedida: a.unidadMedida,
                                existencia: a.existencia,
                                isActive: v,
                              ),
                        ),
                      ],
                    ),
              ),
          icon: const Icon(Icons.add),
          label: const Text('Agregar artículo'),
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
              width: sizeScreen.width * 0.14,
              child: const Text('Descripción'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.14,
              child: const Text('Marca'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.14,
              child: const Text('Unidad de Medida'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.10,
              child: const Text('Existencia'),
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
              width: sizeScreen.width * 0.14,
              child: const Text('Acciones'),
            ),
          ),
        ],
        rowBuilder: (items) {
          return items
              .map(
                (a) => DataRow(
                  cells: [
                    DataCell(Text(a.id.toString())),
                    DataCell(Text(a.descripcion)),
                    DataCell(
                      Text(a.marca.descripcion),
                    ), // Mostrar nombre de la marca
                    DataCell(
                      Text(a.unidadMedida.descripcion),
                    ), // Mostrar nombre de la unidad
                    DataCell(Text(a.existencia.toString())),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color:
                                a.isActive
                                    ? AppColors.success
                                    : AppColors.danger,
                          ),
                        ),
                        backgroundColor:
                            a.isActive
                                ? AppColors.success.withOpacity(0.15)
                                : AppColors.danger.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.06,
                          child: Text(
                            a.isActive ? 'Activo' : 'Inactivo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  a.isActive
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
                                  (_) => GenericFormDialog<Article>(
                                    title: 'Editar Artículo',
                                    initialData: a,
                                    onSubmit: (data) async {
                                      await context
                                          .read<ArticleProvider>()
                                          .actualizarArticulo(data);
                                    },
                                    fromValues:
                                        (values, initial) => Article(
                                          id: initial?.id ?? 0,
                                          descripcion:
                                              values['descripcion'] ??
                                              initial?.descripcion ??
                                              '',
                                          marca:
                                              values['marca'] ?? initial?.marca,
                                          unidadMedida:
                                              values['unidadMedida'] ??
                                              initial?.unidadMedida,
                                          existencia:
                                              int.tryParse(
                                                values['existencia']
                                                        ?.toString() ??
                                                    '',
                                              ) ??
                                              initial?.existencia ??
                                              0,
                                          isActive:
                                              values['isActive'] ??
                                              initial?.isActive ??
                                              true,
                                        ),
                                    fields: [
                                      FormFieldDefinition<Article>(
                                        key: 'descripcion',
                                        label: 'Descripción',
                                        getValue: (a) => a?.descripcion ?? '',
                                        applyValue:
                                            (a, v) => Article(
                                              id: a?.id ?? 0,
                                              descripcion: v,
                                              marca: a!.marca,
                                              unidadMedida: a.unidadMedida,
                                              existencia: a.existencia,
                                              isActive: a.isActive,
                                            ),
                                        validator:
                                            (v) =>
                                                (v == null || v.isEmpty)
                                                    ? 'Campo requerido'
                                                    : null,
                                      ),
                                      FormFieldDefinition<Article>(
                                        key: 'marca',
                                        label: 'Marca',
                                        fieldType: 'dropdown',
                                        options: brandOptions,
                                        getValue: (a) => a?.marca,
                                        applyValue:
                                            (a, v) => Article(
                                              id: a?.id ?? 0,
                                              descripcion: a?.descripcion ?? '',
                                              marca: v as Brand,
                                              unidadMedida: a!.unidadMedida,
                                              existencia: a.existencia,
                                              isActive: a.isActive,
                                            ),
                                        display:
                                            (b) => (b as Brand).descripcion,
                                        validator:
                                            (v) =>
                                                v == null
                                                    ? 'Campo requerido'
                                                    : null,
                                      ),
                                      FormFieldDefinition<Article>(
                                        key: 'unidadMedida',
                                        label: 'Unidad de Medida',
                                        fieldType: 'dropdown',
                                        options: unitOptions,
                                        getValue: (a) => a?.unidadMedida,
                                        applyValue:
                                            (a, v) => Article(
                                              id: a?.id ?? 0,
                                              descripcion: a?.descripcion ?? '',
                                              marca: a!.marca,
                                              unidadMedida: v as Unit,
                                              existencia: a.existencia,
                                              isActive: a.isActive,
                                            ),
                                        display: (u) => (u as Unit).descripcion,
                                        validator:
                                            (v) =>
                                                v == null
                                                    ? 'Campo requerido'
                                                    : null,
                                      ),
                                      FormFieldDefinition<Article>(
                                        key: 'existencia',
                                        label: 'Existencia',
                                        fieldType: 'number',
                                        getValue:
                                            (a) =>
                                                a?.existencia.toString() ?? '0',
                                        applyValue:
                                            (a, v) => Article(
                                              id: a?.id ?? 0,
                                              descripcion: a?.descripcion ?? '',
                                              marca: a!.marca,
                                              unidadMedida: a.unidadMedida,
                                              existencia:
                                                  int.tryParse(v.toString()) ??
                                                  0,
                                              isActive: a.isActive,
                                            ),
                                        validator:
                                            (v) =>
                                                (v == null ||
                                                        v.toString().isEmpty)
                                                    ? 'Campo requerido'
                                                    : null,
                                      ),
                                      FormFieldDefinition<Article>(
                                        key: 'isActive',
                                        label: 'Estado',
                                        fieldType: 'dropdown',
                                        options: [true, false],
                                        getValue: (a) => a?.isActive,
                                        applyValue:
                                            (a, v) => Article(
                                              id: a?.id ?? 0,
                                              descripcion: a?.descripcion ?? '',
                                              marca: a!.marca,
                                              unidadMedida: a.unidadMedida,
                                              existencia: a.existencia,
                                              isActive: v,
                                            ),
                                      ),
                                    ],
                                  ),
                            );
                          } else if (value == 'delete') {
                            context.read<ArticleProvider>().eliminarArticulo(
                              a.id,
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
