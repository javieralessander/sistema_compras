import 'package:flutter/material.dart';

class GenericFormDialog<T> extends StatefulWidget {
  final String title;
  final T? initialData;
  final List<FormFieldDefinition<T>> fields;
  final Future<void> Function(T data) onSubmit;
  final T Function(Map<String, dynamic> values, T? initialData) fromValues;
  final double? dialogWidthFactor; // Factor del ancho de pantalla (ej: 0.6 para 60%)
  final double? dialogHeightFactor; // Factor del alto de pantalla (ej: 0.8 para 80%)
  final double? maxWidth; // Ancho máximo absoluto
  final double? maxHeight; // Alto máximo absoluto

  const GenericFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    required this.fromValues,
    this.initialData,
    this.dialogWidthFactor,
    this.dialogHeightFactor,
    this.maxWidth,
    this.maxHeight,
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
    final screenSize = MediaQuery.of(context).size;
    
    // Calcular el ancho del diálogo
    double dialogWidth;
    if (widget.dialogWidthFactor != null) {
      dialogWidth = screenSize.width * widget.dialogWidthFactor!;
      if (widget.maxWidth != null) {
        dialogWidth = dialogWidth.clamp(0, widget.maxWidth!);
      }
    } else {
      // Valor por defecto
      dialogWidth = screenSize.width > 1200 
          ? screenSize.width * 0.6  // 60% en pantallas grandes
          : screenSize.width > 800 
          ? screenSize.width * 0.75 // 75% en pantallas medianas
          : screenSize.width * 0.9; // 90% en pantallas pequeñas
    }
    
    // Calcular la altura del diálogo
    double? dialogHeight;
    if (widget.dialogHeightFactor != null) {
      dialogHeight = screenSize.height * widget.dialogHeightFactor!;
      if (widget.maxHeight != null) {
        dialogHeight = dialogHeight.clamp(0, widget.maxHeight!);
      }
    }
    
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  widget.fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
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
      actionsPadding: const EdgeInsets.all(24),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Cancelar',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              final data = widget.fromValues(_formValues, widget.initialData);
              await widget.onSubmit(data);
              if (context.mounted) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Guardar',
            style: TextStyle(fontSize: 16),
          ),
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
                      value: opt is Map ? opt['value'] : opt,
                      child: Text(
                        display != null 
                            ? display!(opt) 
                            : opt is Map 
                                ? opt['label'].toString() 
                                : opt.toString(),
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
