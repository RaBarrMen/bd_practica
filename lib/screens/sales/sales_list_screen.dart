import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sales_provider.dart';
import '../../utils/colors.dart';
import '../../models/sale.dart';
import '../../constants/app_styles.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/status_indicator.dart';
import '../../utils/date_utils.dart';
import 'sale_detail_screen.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({Key? key}) : super(key: key);

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SalesProvider>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        return Column(
          children: [
            // Filtros
            Padding(
              padding: const EdgeInsets.all(AppStyles.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            'Todos',
                            null,
                            salesProvider.filterStatus == null,
                            () {
                              salesProvider.filterByStatus(null);
                            },
                          ),
                          const SizedBox(width: AppStyles.paddingSmall),
                          _buildFilterChip(
                            'En Proceso',
                            SaleStatus.pending,
                            salesProvider.filterStatus == SaleStatus.pending,
                            () {
                              salesProvider.filterByStatus(SaleStatus.pending);
                            },
                          ),
                          const SizedBox(width: AppStyles.paddingSmall),
                          _buildFilterChip(
                            'Completados',
                            SaleStatus.completed,
                            salesProvider.filterStatus == SaleStatus.completed,
                            () {
                              salesProvider
                                  .filterByStatus(SaleStatus.completed);
                            },
                          ),
                          const SizedBox(width: AppStyles.paddingSmall),
                          _buildFilterChip(
                            'Cancelados',
                            SaleStatus.cancelled,
                            salesProvider.filterStatus == SaleStatus.cancelled,
                            () {
                              salesProvider.filterByStatus(SaleStatus.cancelled);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Lista de ventas
            Expanded(
              child: salesProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : salesProvider.sales.isEmpty
                      ? const Center(
                          child: Text('Sin ventas registradas'),
                        )
                      : ListView.builder(
                          itemCount: salesProvider.sales.length,
                          itemBuilder: (context, index) {
                            final sale = salesProvider.sales[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppStyles.paddingMedium,
                                vertical: AppStyles.paddingSmall,
                              ),
                              child: Card(
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SaleDetailScreen(sale: sale),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        sale.status.color.withOpacity(0.2),
                                    child: Icon(
                                      sale.status.icon,
                                      color: sale.status.color,
                                    ),
                                  ),
                                  title: Text(
                                    sale.clientName,
                                    style: AppStyles.bodyLarge,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                          height: AppStyles.paddingXSmall),
                                      Text(
                                        '${sale.saleType.label} - ${DateTimeUtils.formatShortDate(sale.saleDate)}',
                                        style: AppStyles.bodySmall,
                                      ),
                                      const SizedBox(
                                        height: AppStyles.paddingXSmall,
                                      ),
                                      FutureBuilder<String>(
                                        future: salesProvider
                                            .getSaleProductsSummary(sale.id),
                                        builder: (context, snapshot) {
                                          final summary = snapshot.data;
                                          if (summary == null ||
                                              summary == 'Sin productos') {
                                            return const SizedBox.shrink();
                                          }
                                          return Text(
                                            'Productos: $summary',
                                            style: AppStyles.bodySmall.copyWith(
                                              color: AppColors.primary,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                          height: AppStyles.paddingXSmall),
                                      StatusBadge(status: sale.status),
                                    ],
                                  ),
                                  trailing: Text(
                                    '\$${sale.totalAmount.toStringAsFixed(2)}',
                                    style: AppStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    SaleStatus? status,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.greyLight,
      selectedColor: status?.color ?? AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}