import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/status_widget.dart';
import '../models/purchase_order_model.dart';

class PurchaseOrderDetailDialog extends StatelessWidget {
  final PurchaseOrder orden;

  const PurchaseOrderDetailDialog({
    super.key,
    required this.orden,
  });

  @override
  Widget build(BuildContext context) {
    final costoTotal = orden.items.isNotEmpty && orden.estado != PurchaseOrder.ESTADO_GENERADA
        ? orden.items.fold<double>(0, (sum, item) => sum + (item.costoUnitario * item.cantidad))
        : 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Orden de Compra #${orden.numeroOrden}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Solicitud #${orden.idSolicitud}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información general
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            'Fecha de Orden',
                            orden.fechaOrden.toIso8601String().split('T').first,
                            Icons.calendar_today,
                            AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCardWithStatusWidget(
                            'Estado',
                            orden.estado,
                            Icons.flag,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            'Costo Total',
                            orden.estado == PurchaseOrder.ESTADO_GENERADA 
                                ? 'Pendiente asignación' 
                                : costoTotal > 0 ? '\$${costoTotal.toStringAsFixed(2)}' : 'No asignado',
                            Icons.attach_money,
                            orden.estado == PurchaseOrder.ESTADO_GENERADA 
                                ? AppColors.warning 
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Título de artículos
                    Row(
                      children: [
                        Icon(Icons.inventory_2, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Artículos Solicitados (${orden.items.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutralDark,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Lista de artículos
                    Expanded(
                      child: orden.items.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: orden.items.length,
                              itemBuilder: (context, index) {
                                final item = orden.items[index];
                                return _buildItemCard(item, index + 1);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.light.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardWithStatusWidget(String title, String estado, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatusWidget.purchaseOrder(
            estado,
            showIcon: true,
            showBorder: true,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(PurchaseOrderItem item, int numero) {
    final subtotal = orden.estado != PurchaseOrder.ESTADO_GENERADA 
        ? item.costoUnitario * item.cantidad 
        : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Número del item
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                numero.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Información del artículo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.articulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Marca: ${item.marca}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDetailChip(
                      'Cantidad',
                      '${item.cantidad}',
                      Icons.numbers,
                      AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      'Unidad',
                      item.unidadMedida,
                      Icons.straighten,
                      AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      'Costo Unit.',
                      orden.estado == PurchaseOrder.ESTADO_GENERADA 
                          ? 'Pendiente' 
                          : item.costoUnitario > 0 ? '\$${item.costoUnitario.toStringAsFixed(2)}' : 'No asignado',
                      Icons.attach_money,
                      orden.estado == PurchaseOrder.ESTADO_GENERADA 
                          ? AppColors.warning 
                          : AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Subtotal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: orden.estado == PurchaseOrder.ESTADO_GENERADA 
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                ),
                Text(
                  orden.estado == PurchaseOrder.ESTADO_GENERADA 
                      ? 'Pendiente'
                      : subtotal > 0 ? '\$${subtotal.toStringAsFixed(2)}' : 'No calculado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: orden.estado == PurchaseOrder.ESTADO_GENERADA 
                        ? AppColors.warning 
                        : AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.gray,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay artículos en esta orden',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los items no se han cargado desde el backend',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}
