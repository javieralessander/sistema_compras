import 'package:flutter/material.dart';
import '../../core/config/app_theme.dart';
import '../../features/modules/article/models/article_model.dart';
import '../../features/modules/unit/models/unit_model.dart';
import '../../features/modules/request_articles/models/request_articles_model.dart';

class MultiArticleFormField extends StatefulWidget {
  final List<RequestArticleItem> initialItems;
  final List<Article> articleOptions;
  final List<Unit> unitOptions;
  final void Function(List<RequestArticleItem>) onChanged;

  const MultiArticleFormField({
    super.key,
    required this.initialItems,
    required this.articleOptions,
    required this.unitOptions,
    required this.onChanged,
  });

  @override
  State<MultiArticleFormField> createState() => _MultiArticleFormFieldState();
}

class _MultiArticleFormFieldState extends State<MultiArticleFormField> {
  late List<RequestArticleItem> items;

  @override
  void initState() {
    super.initState();
    items = List<RequestArticleItem>.from(widget.initialItems);
  }

  void _addItem() {
    if (widget.articleOptions.isEmpty || widget.unitOptions.isEmpty) return;
    
    setState(() {
      // Crear artículo dummy para campos en blanco
      final dummyArticle = Article(
        id: 0,
        descripcion: 'Seleccione un artículo...',
        marca: widget.articleOptions.first.marca, // Usar marca temporal
        unidadMedida: widget.unitOptions.first, // Unidad temporal
        existencia: 0,
        isActive: true,
      );
      
      items.add(RequestArticleItem(
        articulo: dummyArticle,
        cantidad: 1,
        unidadMedida: widget.unitOptions.first,
      ));
      widget.onChanged(items);
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      widget.onChanged(items);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayLight),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.light.withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Artículos Solicitados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} ${items.length == 1 ? 'artículo' : 'artículos'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Lista de artículos
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.grayLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grayLight, style: BorderStyle.solid),
              ),
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.gray),
                  const SizedBox(height: 8),
                  Text(
                    'No hay artículos agregados',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Haz clic en "Agregar artículo" para comenzar',
                    style: TextStyle(
                      color: AppColors.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grayLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isMobile ? _buildMobileLayout(i, item) : _buildDesktopLayout(i, item),
                ),
              );
            }),
          
          const SizedBox(height: 16),
          
          // Botón agregar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.articleOptions.isEmpty || widget.unitOptions.isEmpty 
                  ? null 
                  : _addItem,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Agregar artículo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(int index, RequestArticleItem item) {
    return Row(
      children: [
        // Número del item
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        
        // Artículo
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Artículo',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<Article?>(
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                value: item.articulo.id == 0 ? null : item.articulo, // Si es dummy, mostrar null
                items: [
                  // Opción en blanco al inicio
                  DropdownMenuItem<Article?>(
                    value: null,
                    child: Text(
                      'Seleccione un artículo...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Artículos disponibles
                  ...widget.articleOptions
                      .map((a) => DropdownMenuItem<Article?>(
                            value: a,
                            child: Text(
                              a.descripcion,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      // Asignar automáticamente la unidad de medida del artículo seleccionado
                      items[index] = RequestArticleItem(
                        articulo: value,
                        cantidad: item.cantidad,
                        unidadMedida: value.unidadMedida, // Unidad automática del artículo
                      );
                    } else {
                      // Si se selecciona "en blanco", mantener el estado actual
                      items[index] = RequestArticleItem(
                        articulo: Article(
                          id: 0,
                          descripcion: 'Seleccione un artículo...',
                          marca: widget.articleOptions.first.marca,
                          unidadMedida: widget.unitOptions.first,
                          existencia: 0,
                          isActive: true,
                        ),
                        cantidad: item.cantidad,
                        unidadMedida: widget.unitOptions.first,
                      );
                    }
                    widget.onChanged(items);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Cantidad
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cantidad',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: item.cantidad.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.grayLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    items[index] = RequestArticleItem(
                      articulo: item.articulo,
                      cantidad: int.tryParse(value) ?? 1,
                      unidadMedida: item.unidadMedida,
                    );
                    widget.onChanged(items);
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Unidad
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unidad',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: item.articulo.id != 0 
                      ? AppColors.grayLight.withValues(alpha: 0.3) 
                      : Colors.transparent,
                  border: Border.all(color: AppColors.grayLight),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: item.articulo.id != 0 ? AppColors.primary : AppColors.gray,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.articulo.id != 0 
                            ? '${item.unidadMedida.descripcion} (automático)'
                            : 'Seleccione artículo primero',
                        style: TextStyle(
                          fontSize: 14,
                          color: item.articulo.id != 0 ? AppColors.neutralDark : AppColors.gray,
                          fontStyle: item.articulo.id == 0 ? FontStyle.italic : FontStyle.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Botón eliminar
        IconButton(
          icon: Icon(Icons.delete_outline, color: AppColors.danger),
          tooltip: 'Eliminar artículo',
          onPressed: () => _removeItem(index),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.danger.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(int index, RequestArticleItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con número y botón eliminar
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Artículo ${index + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDark,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
              tooltip: 'Eliminar artículo',
              onPressed: () => _removeItem(index),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                minimumSize: const Size(32, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Artículo
        Text(
          'Artículo',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<Article>(
          value: item.articulo,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.grayLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.grayLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          items: widget.articleOptions
              .map((a) => DropdownMenuItem(
                    value: a,
                    child: Text(
                      a.descripcion,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              items[index] = RequestArticleItem(
                articulo: value!,
                cantidad: item.cantidad,
                unidadMedida: item.unidadMedida,
              );
              widget.onChanged(items);
            });
          },
        ),
        const SizedBox(height: 12),
        
        // Cantidad y Unidad en fila
        Row(
          children: [
            // Cantidad
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cantidad',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: item.cantidad.toString(),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.grayLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.grayLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        items[index] = RequestArticleItem(
                          articulo: item.articulo,
                          cantidad: int.tryParse(value) ?? 1,
                          unidadMedida: item.unidadMedida,
                        );
                        widget.onChanged(items);
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Unidad
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unidad',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<Unit>(
                    value: item.unidadMedida,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.grayLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.grayLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: widget.unitOptions
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(
                                u.descripcion,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        items[index] = RequestArticleItem(
                          articulo: item.articulo,
                          cantidad: item.cantidad,
                          unidadMedida: value!,
                        );
                        widget.onChanged(items);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}