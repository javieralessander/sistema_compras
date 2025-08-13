import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../models/purchase_order_model.dart';

class ChangeStatusDialog extends StatefulWidget {
  final PurchaseOrder orden;
  final Function(String nuevoEstado, Map<int, double>? costos) onStatusChanged;

  const ChangeStatusDialog({
    super.key,
    required this.orden,
    required this.onStatusChanged,
  });

  @override
  State<ChangeStatusDialog> createState() => _ChangeStatusDialogState();
}

class _ChangeStatusDialogState extends State<ChangeStatusDialog> {
  late String _estadoSeleccionado;
  final Map<int, TextEditingController> _costosControllers = {};
  bool _mostrarCostos = false;

  @override
  void initState() {
    super.initState();
    
    // Si hay estados disponibles, seleccionar el primero, si no, mantener el actual
    final estadosDisp = _estadosDisponibles;
    _estadoSeleccionado = estadosDisp.isNotEmpty ? estadosDisp.first : widget.orden.estado;
    
    // Inicializar controladores para cada item
    for (final item in widget.orden.items) {
      // Para órdenes en estado GENERADA, mostrar costo 0
      // Para otros estados, mostrar el costo actual
      final costoInicial = widget.orden.estado == PurchaseOrder.ESTADO_GENERADA 
          ? '0' 
          : item.costoUnitario.toString();
      
      _costosControllers[item.hashCode] = TextEditingController(
        text: costoInicial,
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _costosControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> get _estadosDisponibles {
    // Definir transiciones de estados válidas (excluyendo el estado actual)
    switch (widget.orden.estado) {
      case PurchaseOrder.ESTADO_GENERADA:
        return [
          PurchaseOrder.ESTADO_PROCESADA,
          PurchaseOrder.ESTADO_CANCELADA,
        ];
      case PurchaseOrder.ESTADO_PROCESADA:
        return [
          PurchaseOrder.ESTADO_COMPLETADA,
          PurchaseOrder.ESTADO_CANCELADA,
        ];
      case PurchaseOrder.ESTADO_COMPLETADA:
        return []; // No se puede cambiar (estado final)
      case PurchaseOrder.ESTADO_CANCELADA:
        return []; // No se puede cambiar (estado final)
      default:
        return [];
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case PurchaseOrder.ESTADO_GENERADA:
        return 'Generada';
      case PurchaseOrder.ESTADO_PROCESADA:
        return 'Procesada';
      case PurchaseOrder.ESTADO_COMPLETADA:
        return 'Completada';
      case PurchaseOrder.ESTADO_CANCELADA:
        return 'Cancelada';
      default:
        return estado;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case PurchaseOrder.ESTADO_GENERADA:
        return AppColors.info;
      case PurchaseOrder.ESTADO_PROCESADA:
        return AppColors.warning;
      case PurchaseOrder.ESTADO_COMPLETADA:
        return AppColors.success;
      case PurchaseOrder.ESTADO_CANCELADA:
        return AppColors.danger;
      default:
        return AppColors.gray;
    }
  }

  bool _requiereCostos(String estado) {
    // Habilitar asignación de costos cuando se procesa una orden
    return estado == PurchaseOrder.ESTADO_PROCESADA;
    // Por ahora solo para PROCESADA, luego se puede extender a COMPLETADA
  }

  Map<int, double>? _obtenerCostos() {
    if (!_mostrarCostos) return null;
    
    final costos = <int, double>{};
    int itemIndex = 0;
    
    for (final item in widget.orden.items) {
      final controller = _costosControllers[item.hashCode];
      if (controller != null) {
        final costo = double.tryParse(controller.text);
        if (costo != null) {
          // Por ahora usar el índice del item como key
          // El backend deberá mapear esto correctamente
          costos[itemIndex] = costo;
        }
      }
      itemIndex++;
    }
    
    return costos.isEmpty ? null : costos;
  }

  @override
  Widget build(BuildContext context) {
    final estadosDisponibles = _estadosDisponibles;
    
    // Si no hay estados disponibles, mostrar mensaje informativo
    if (estadosDisponibles.isEmpty) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: AppColors.info),
            const SizedBox(width: 8),
            Text('Estado de Orden #${widget.orden.numeroOrden}'),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getEstadoColor(widget.orden.estado).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getEstadoColor(widget.orden.estado)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.flag,
                color: _getEstadoColor(widget.orden.estado),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Estado Actual: ${_getEstadoLabel(widget.orden.estado)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getEstadoColor(widget.orden.estado),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Esta orden no puede cambiar de estado',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      );
    }
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.assignment, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Cambiar Estado de Orden #${widget.orden.numeroOrden}'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado actual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getEstadoColor(widget.orden.estado).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getEstadoColor(widget.orden.estado)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _getEstadoColor(widget.orden.estado),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estado actual: ${_getEstadoLabel(widget.orden.estado)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _getEstadoColor(widget.orden.estado),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Selector de nuevo estado
            Text(
              'Nuevo Estado',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralDark,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _estadoSeleccionado,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _estadosDisponibles.map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getEstadoColor(estado),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_getEstadoLabel(estado)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _estadoSeleccionado = value!;
                  _mostrarCostos = _requiereCostos(value);
                });
              },
            ),
            
            // Sección de costos (si es necesario)
            if (_mostrarCostos) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Asignar costos a los productos para el estado "${_getEstadoLabel(_estadoSeleccionado)}"',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Lista de items para asignar costos
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: widget.orden.items.asMap().entries.map((entry) {
                      final item = entry.value;
                      final controller = _costosControllers[item.hashCode]!;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grayLight),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.articulo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.cantidad} ${item.unidadMedida} - ${item.marca}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Costo unitario: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray,
                                  ),
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      prefixText: '\$',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Verificar si podemos hacer pop de forma segura
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              // Fallback si no se puede hacer pop
              try {
                Navigator.of(context, rootNavigator: true).pop();
              } catch (e) {
                print('Error al cerrar diálogo: $e');
              }
            }
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final costos = _obtenerCostos();
            // No hacer pop aquí, dejar que el parent maneje la navegación
            widget.onStatusChanged(_estadoSeleccionado, costos);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _getEstadoColor(_estadoSeleccionado),
            foregroundColor: Colors.white,
          ),
          child: Text('Cambiar a "${_getEstadoLabel(_estadoSeleccionado)}"'),
        ),
      ],
    );
  }
}
