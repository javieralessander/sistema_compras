import 'package:flutter/material.dart';
import '../../features/modules/article/models/article_model.dart';
import '../../features/modules/unit/models/unit_model.dart';
import '../../features/modules/request_articles/models/request_articles_model.dart';

// ...resto del código...
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
    setState(() {
      items.add(RequestArticleItem(
        articulo: widget.articleOptions.first,
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
    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Artículo
              DropdownButton<Article>(
                value: item.articulo,
                items: widget.articleOptions
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(a.descripcion),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    items[i] = RequestArticleItem(
                      articulo: value!,
                      cantidad: item.cantidad,
                      unidadMedida: item.unidadMedida,
                    );
                    widget.onChanged(items);
                  });
                },
              ),
              // Cantidad
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: item.cantidad.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      items[i] = RequestArticleItem(
                        articulo: item.articulo,
                        cantidad: int.tryParse(value) ?? 1,
                        unidadMedida: item.unidadMedida,
                      );
                      widget.onChanged(items);
                    });
                  },
                ),
              ),
              // Unidad
              DropdownButton<Unit>(
                value: item.unidadMedida,
                items: widget.unitOptions
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(u.descripcion),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    items[i] = RequestArticleItem(
                      articulo: item.articulo,
                      cantidad: item.cantidad,
                      unidadMedida: value!,
                    );
                    widget.onChanged(items);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeItem(i),
              ),
            ],
          );
        }),
        TextButton.icon(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: const Text('Agregar artículo'),
        ),
      ],
    );
  }
}