import 'package:flutter/material.dart';

class GenericFormDialog<T> extends StatefulWidget {
  final String title;
  final T? initialData;
  final List<FormFieldDefinition<T>> fields;
  final Future<void> Function(T data) onSubmit;
  final T Function(Map<String, dynamic> values, T? initialData) fromValues;

  const GenericFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    required this.fromValues,
    this.initialData,
  });

  @override
  State<GenericFormDialog<T>> createState() => _GenericFormDialogState<T>();
}

class _GenericFormDialogState<T> extends State<GenericFormDialog<T>> {
  final Map<String, dynamic> _formValues = {};
  final _formKey = GlobalKey<FormState>();

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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  widget.fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: field.buildField(
                        context,
                        _formValues[field.key],
                        (value) =>
                            setState(() => _formValues[field.key] = value),
                        widget.initialData,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final data = widget.fromValues(_formValues, widget.initialData);
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
  final String fieldType; // 'text' | 'dropdown' | 'number' | 'custom'
  final List<dynamic>? options;
  final dynamic Function(T?) getValue;
  final T? Function(T?, dynamic) applyValue;
  final String? Function(dynamic)? validator;
  final String Function(dynamic)? display;
  final Widget Function(
    BuildContext context,
    _FormFieldController controller,
    T? initialData,
  )?
  builder; // <-- Agregado

  FormFieldDefinition({
    required this.key,
    required this.label,
    required this.getValue,
    required this.applyValue,
    this.fieldType = 'text',
    this.options,
    this.validator,
    this.display,
    this.builder, // <-- Agregado
  });

  Widget buildField(
    BuildContext context,
    dynamic value,
    Function(dynamic) onChanged, [
    T? initialData,
  ]) {
    if (fieldType == 'custom' && builder != null) {
      return builder!(
        context,
        _FormFieldController(value: value, setValue: onChanged),
        initialData,
      );
    }
    switch (fieldType) {
      case 'dropdown':
        return DropdownButtonFormField<dynamic>(
          value: value,
          decoration: InputDecoration(labelText: label),
          items:
              options!
                  .map(
                    (opt) => DropdownMenuItem<dynamic>(
                      value: opt,
                      child: Text(
                        display != null ? display!(opt) : opt.toString(),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          validator: validator,
        );
      case 'number':
        return TextFormField(
          initialValue: value?.toString(),
          decoration: InputDecoration(labelText: label),
          keyboardType: TextInputType.number,
          onChanged: (v) => onChanged(int.tryParse(v)),
          validator: validator,
        );
      case 'date':
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(labelText: label),
            child: Text(
              value != null
                  ? (value is DateTime
                      ? value.toIso8601String().split('T').first
                      : value.toString())
                  : '',
            ),
          ),
        );
      default:
        return TextFormField(
          initialValue: value,
          decoration: InputDecoration(labelText: label),
          onChanged: onChanged,
          validator: validator,
        );
    }
  }
}

// Controlador para campos personalizados
class _FormFieldController {
  dynamic value;
  final void Function(dynamic) setValue;
  _FormFieldController({required this.value, required this.setValue});
}
