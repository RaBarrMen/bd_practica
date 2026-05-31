import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_styles.dart';
import '../../models/sale.dart';
import '../../models/sale_detail.dart';
import '../../models/product.dart';
import '../../providers/sales_provider.dart';
import '../../utils/colors.dart';
import '../../utils/date_utils.dart';
import '../../widgets/status_badge.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailScreen({Key? key, required this.sale}) : super(key: key);

  Future<void> _changeStatusWithConfirmation({
    required BuildContext context,
    required SalesProvider salesProvider,
    required int saleId,
    required SaleStatus status,
    required String title,
    required String message,
    required String successMessage,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await salesProvider.updateSaleStatus(saleId, status);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? successMessage : (salesProvider.error ?? 'No se pudo actualizar la venta'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<SalesProvider>(
        builder: (context, salesProvider, _) {
          final currentSale = salesProvider.getSaleById(sale.id) ?? sale;
          final details = salesProvider.getSaleDetails(currentSale.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Número de Venta', style: AppStyles.bodySmall),
                                  const SizedBox(height: AppStyles.paddingXSmall),
                                  Text(currentSale.saleNumber, style: AppStyles.labelLarge),
                                ],
                              ),
                            ),
                            StatusBadge(status: currentSale.status),
                          ],
                        ),
                        const SizedBox(height: AppStyles.paddingMedium),
                        _buildDetailRow('Cliente:', currentSale.clientName),
                        const SizedBox(height: AppStyles.paddingSmall),
                        if (currentSale.clientPhone != null)
                          Column(
                            children: [
                              _buildDetailRow('Teléfono:', currentSale.clientPhone!),
                              const SizedBox(height: AppStyles.paddingSmall),
                            ],
                          ),
                        if (currentSale.clientEmail != null)
                          Column(
                            children: [
                              _buildDetailRow('Email:', currentSale.clientEmail!),
                              const SizedBox(height: AppStyles.paddingSmall),
                            ],
                          ),
                        _buildDetailRow('Tipo:', currentSale.saleType.label),
                        const SizedBox(height: AppStyles.paddingSmall),
                        _buildDetailRow(
                          'Fecha de Venta:',
                          DateTimeUtils.formatDateWithTime(currentSale.saleDate),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppStyles.paddingMedium),
                Text('Artículos', style: AppStyles.headlineSmall),
                const SizedBox(height: AppStyles.paddingSmall),
                if (details.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppStyles.paddingMedium),
                      child: Center(child: Text('Sin artículos')),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final detail = details[index];
                      final product = salesProvider.getProductForDetail(detail);
                      return _buildProductDetailCard(detail: detail, product: product);
                    },
                  ),
                const SizedBox(height: AppStyles.paddingMedium),
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.paddingMedium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: AppStyles.headlineSmall),
                        Text(
                          '\$${currentSale.totalAmount.toStringAsFixed(2)}',
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppStyles.paddingMedium),
                if (currentSale.status == SaleStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppStyles.paddingSmall),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _changeStatusWithConfirmation(
                          context: context,
                          salesProvider: salesProvider,
                          saleId: currentSale.id,
                          status: SaleStatus.completed,
                          title: 'Completar venta',
                          message: '¿Deseas marcar esta venta como completada?',
                          successMessage: 'Venta marcada como completada',
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Marcar como completada'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusCompleted,
                        ),
                      ),
                    ),
                  ),
                if (currentSale.status == SaleStatus.cancelled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _changeStatusWithConfirmation(
                        context: context,
                        salesProvider: salesProvider,
                        saleId: currentSale.id,
                        status: SaleStatus.pending,
                        title: 'Reactivar venta',
                        message: 'La venta volverá a estado "En Proceso". ¿Continuar?',
                        successMessage: 'Venta reactivada correctamente',
                      ),
                      icon: const Icon(Icons.restore),
                      label: const Text('Reactivar venta'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _changeStatusWithConfirmation(
                        context: context,
                        salesProvider: salesProvider,
                        saleId: currentSale.id,
                        status: SaleStatus.cancelled,
                        title: 'Cancelar venta',
                        message: '¿Seguro que deseas cancelar esta venta?',
                        successMessage: 'Venta cancelada',
                      ),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar venta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusCancelled,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductDetailCard({
    required SaleDetail detail,
    required Product? product,
  }) {
    final productName = product?.name ?? 'Producto #${detail.productId}';
    final description = (product?.description ?? '').trim();
    final unit = (product?.unit ?? 'unidad').trim();

    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingSmall),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                const SizedBox(width: AppStyles.paddingSmall),
                Expanded(
                  child: Text(productName, style: AppStyles.labelLarge),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: AppStyles.paddingSmall),
              Text(description, style: AppStyles.bodySmall),
            ],
            const SizedBox(height: AppStyles.paddingSmall),
            _buildDetailRow('Cantidad:', '${detail.quantity.toStringAsFixed(2)} $unit'),
            const SizedBox(height: AppStyles.paddingXSmall),
            _buildDetailRow('Precio unitario:', '\$${detail.unitPrice.toStringAsFixed(2)}'),
            const SizedBox(height: AppStyles.paddingXSmall),
            _buildDetailRow('Subtotal:', '\$${detail.subtotal.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppStyles.bodySmall),
        Flexible(
          child: Text(
            value,
            style: AppStyles.labelLarge,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
