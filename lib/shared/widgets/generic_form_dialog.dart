import 'package:flutter/material.dart';

class GenericFormDialog<T> extends StatefulWidget {
  final String title;
  final T? initialData;
  final List<FormFieldDefinition<T>> fields;
  final Future<void> Function(T data) onSubmit;

  const GenericFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    this.initialData,
  });

  @override
  State<GenericFormDialog<T>> createState() => _GenericFormDialogState<T>();
}

class _GenericFormDialogState<T> extends State<GenericFormDialog<T>> {
  final Map<String, dynamic> _formValues = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _formValues[field.key] = field.getValue(widget.initialData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.fields.map((field) {
            return field.buildField(
              context,
              _formValues[field.key],
              (value) => setState(() => _formValues[field.key] = value),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final data = widget.fields.fold<T?>(widget.initialData, (prev, field) {
              return field.applyValue(prev, _formValues[field.key]);
            });
            if (data != null) {
              await widget.onSubmit(data);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class FormFieldDefinition<T> {
  final String key;
  final String label;
  final String fieldType; // 'text' | 'dropdown'
  final List<String>? options;
  final dynamic Function(T?) getValue;
  final T? Function(T?, dynamic) applyValue;

  FormFieldDefinition({
    required this.key,
    required this.label,
    required this.getValue,
    required this.applyValue,
    this.fieldType = 'text',
    this.options,
  });

  Widget buildField(
    BuildContext context,
    dynamic value,
    Function(dynamic) onChanged,
  ) {
    switch (fieldType) {
      case 'dropdown':
        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(labelText: label),
          items: options!
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  ))
              .toList(),
          onChanged: onChanged,
        );
      default:
        return TextFormField(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          onChanged: onChanged,
        );
    }
  }
}