import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../shared/widgets/status_widget.dart';
import '../models/request_articles_model.dart';

class RequestArticlesDetailDialog extends StatelessWidget {
  final RequestArticles solicitud;

  const RequestArticlesDetailDialog({
    super.key,
    required this.solicitud,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.assignment_outlined, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitud de Artículos #${solicitud.id}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Solicitante: ${solicitud.empleadoSolicitante.nombre}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text(
                      'Cerrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                            'Fecha de Solicitud',
                            solicitud.fechaSolicitud.toIso8601String().split('T').first,
                            Icons.calendar_today,
                            AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCardWithStatusWidget(
                            'Estado',
                            solicitud.estado,
                            Icons.flag,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            'Empleado',
                            solicitud.empleadoSolicitante.nombre,
                            Icons.person,
                            AppColors.info,
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
                          'Artículos Solicitados (${solicitud.items.length})',
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
                      child: solicitud.items.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              itemCount: solicitud.items.length,
                              itemBuilder: (context, index) {
                                final item = solicitud.items[index];
                                return _buildItemCard(item, index + 1);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer con información del estado
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
                children: [
                  Expanded(
                    child: _buildStatusInfo(),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text(
                      'Cerrar',
                      style: TextStyle(fontWeight: FontWeight.w600),
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
        color: AppColors.light.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gray, size: 20),
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
          StatusWidget.request(
            estado,
            showIcon: true,
            showBorder: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(RequestArticleItem item, int numero) {
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
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary),
            ),
            child: Center(
              child: Text(
                numero.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.articulo.descripcion,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(Icons.inventory, size: 16, color: AppColors.gray),
                    const SizedBox(width: 4),
                    Text(
                      'Artículo: ${item.articulo.descripcion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.straighten, size: 16, color: AppColors.gray),
                    const SizedBox(width: 4),
                    Text(
                      'Unidad: ${item.unidadMedida.descripcion}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Cantidad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success),
            ),
            child: Column(
              children: [
                Text(
                  'Cantidad',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.cantidad.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
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
            'No hay artículos en esta solicitud',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo() {
    String mensaje;
    IconData icono;
    Color color;

    switch (solicitud.estado) {
      case RequestArticles.ESTADO_PENDIENTE:
        mensaje = 'Esta solicitud está pendiente de revisión por el departamento de compras.';
        icono = Icons.schedule;
        color = AppColors.warning;
        break;
      case RequestArticles.ESTADO_APROBADA:
        mensaje = 'Esta solicitud ha sido aprobada y se ha generado automáticamente una orden de compra.';
        icono = Icons.check_circle;
        color = AppColors.success;
        break;
      case RequestArticles.ESTADO_RECHAZADA:
        mensaje = 'Esta solicitud ha sido rechazada por el departamento de compras.';
        icono = Icons.cancel;
        color = AppColors.danger;
        break;
      default:
        mensaje = 'Estado de la solicitud: ${solicitud.estado}';
        icono = Icons.info;
        color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
