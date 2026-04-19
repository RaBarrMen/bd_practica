import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale.dart';
import '../../providers/sales_provider.dart';
import '../../utils/colors.dart';
import '../../constants/app_styles.dart';
import '../../widgets/status_badge.dart';
import '../../utils/date_utils.dart';
import '../sales/sale_detail_screen.dart';

class DayModal extends StatelessWidget {
  final DateTime date;
  final List<Sale> sales;

  const DayModal({
    Key? key,
    required this.date,
    required this.sales,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppStyles.borderRadiusLarge),
              topRight: Radius.circular(AppStyles.borderRadiusLarge),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppStyles.borderRadiusLarge),
                    topRight: Radius.circular(AppStyles.borderRadiusLarge),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ventas del Día',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppStyles.paddingXSmall),
                          Text(
                            DateTimeUtils.formatLongDate(date),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Lista de ventas
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingMedium,
                        vertical: AppStyles.paddingSmall,
                      ),
                      child: Card(
                        elevation: AppStyles.elevationSmall,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SaleDetailScreen(sale: sale),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppStyles.paddingMedium,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sale.clientName,
                                            style: AppStyles.labelLarge,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            height: AppStyles.paddingXSmall,
                                          ),
                                          Text(
                                            sale.saleNumber,
                                            style: AppStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      sale.saleType.icon,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: AppStyles.paddingSmall,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    StatusBadge(status: sale.status),
                                    Text(
                                      '\$${sale.totalAmount.toStringAsFixed(2)}',
                                      style: AppStyles.labelLarge.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: AppStyles.paddingSmall,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: AppColors.grey,
                                    ),
                                    const SizedBox(
                                      width: AppStyles.paddingXSmall,
                                    ),
                                    Text(
                                      DateTimeUtils.formatTime(sale.saleDate),
                                      style: AppStyles.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Footer con resumen
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppStyles.borderRadiusLarge),
                    bottomRight: Radius.circular(AppStyles.borderRadiusLarge),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total del Día',
                          style: AppStyles.bodySmall,
                        ),
                        const SizedBox(height: AppStyles.paddingXSmall),
                        Text(
                          '\$${_calculateTotal(sales).toStringAsFixed(2)}',
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total de Ventas',
                          style: AppStyles.bodySmall,
                        ),
                        const SizedBox(height: AppStyles.paddingXSmall),
                        Text(
                          sales.length.toString(),
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTotal(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.totalAmount);
  }
}