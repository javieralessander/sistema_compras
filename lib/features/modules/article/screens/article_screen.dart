import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/generic_appbar.dart';
import '../../../../shared/widgets/generic_data_table.dart';
import '../../../../shared/widgets/generic_form_dialog.dart';
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
          onPressed: () => showDialog(
            context: context,
            builder: (_) => GenericFormDialog<Article>(
              title: 'Agregar Artículo',
              onSubmit: (data) async => provider.agregarArticulo(data),
              fields: [
                FormFieldDefinition<Article>(
                  key: 'descripcion',
                  label: 'Descripción',
                  getValue: (a) => a?.descripcion ?? '',
                  applyValue: (a, v) => Article(
                    id: a?.id ?? 0,
                    descripcion: v,
                    marca: a?.marca ?? '',
                    unidadMedida: a?.unidadMedida ?? '',
                    existencia: a?.existencia ?? 0,
                    estado: a?.estado ?? 'Activo',
                  ),
                ),
                FormFieldDefinition<Article>(
                  key: 'marca',
                  label: 'Marca',
                  getValue: (a) => a?.marca ?? '',
                  applyValue: (a, v) => Article(
                    id: a?.id ?? 0,
                    descripcion: a?.descripcion ?? '',
                    marca: v,
                    unidadMedida: a?.unidadMedida ?? '',
                    existencia: a?.existencia ?? 0,
                    estado: a?.estado ?? 'Activo',
                  ),
                ),
                FormFieldDefinition<Article>(
                  key: 'unidadMedida',
                  label: 'Unidad de Medida',
                  getValue: (a) => a?.unidadMedida ?? '',
                  applyValue: (a, v) => Article(
                    id: a?.id ?? 0,
                    descripcion: a?.descripcion ?? '',
                    marca: a?.marca ?? '',
                    unidadMedida: v,
                    existencia: a?.existencia ?? 0,
                    estado: a?.estado ?? 'Activo',
                  ),
                ),
                FormFieldDefinition<Article>(
                  key: 'existencia',
                  label: 'Existencia',
                  fieldType: 'number',
                  getValue: (a) => a?.existencia.toString() ?? '0',
                  applyValue: (a, v) => Article(
                    id: a?.id ?? 0,
                    descripcion: a?.descripcion ?? '',
                    marca: a?.marca ?? '',
                    unidadMedida: a?.unidadMedida ?? '',
                    existencia: int.tryParse(v) ?? 0,
                    estado: a?.estado ?? 'Activo',
                  ),
                ),
                FormFieldDefinition<Article>(
                  key: 'estado',
                  label: 'Estado',
                  fieldType: 'dropdown',
                  options: ['Activo', 'Inactivo'],
                  getValue: (a) => a?.estado ?? 'Activo',
                  applyValue: (a, v) => Article(
                    id: a?.id ?? 0,
                    descripcion: a?.descripcion ?? '',
                    marca: a?.marca ?? '',
                    unidadMedida: a?.unidadMedida ?? '',
                    existencia: a?.existencia ?? 0,
                    estado: v,
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
              width: sizeScreen.width * 0.14,
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
              width: sizeScreen.width * 0.14,
              child: const Text('Existencia'),
            ),
          ),
          DataColumn(
            label: SizedBox(
              width: sizeScreen.width * 0.14,
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
                    DataCell(Text(a.marca)),
                    DataCell(Text(a.unidadMedida)),
                    DataCell(Text(a.existencia.toString())),
                    DataCell(
                      Chip(
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: a.estado == 'Activo'
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        backgroundColor: a.estado == 'Activo'
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.danger.withOpacity(0.15),
                        label: SizedBox(
                          width: sizeScreen.width * 0.06,
                          child: Text(
                            a.estado,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: a.estado == 'Activo'
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
                            context.read<ArticleProvider>().eliminarArticulo(
                              a.id,
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