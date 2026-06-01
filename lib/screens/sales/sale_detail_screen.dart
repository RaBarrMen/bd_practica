import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale.dart';
import '../../providers/sales_provider.dart';
import '../../utils/colors.dart';
import '../../constants/app_styles.dart';
import '../../widgets/status_badge.dart';
import '../../utils/date_utils.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailScreen({
    Key? key,
    required this.sale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Venta'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<SalesProvider>(
        builder: (context, salesProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
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
                                    'Número de Venta',
                                    style: AppStyles.bodySmall,
                                  ),
                                  const SizedBox(
                                    height:
                                        AppStyles.paddingXSmall,
                                  ),
                                  Text(
                                    sale.saleNumber,
                                    style: AppStyles.labelLarge,
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(status: sale.status),
                          ],
                        ),
                        const SizedBox(
                          height: AppStyles.paddingMedium,
                        ),
                        _buildDetailRow(
                          'Cliente:',
                          sale.clientName,
                        ),
                        const SizedBox(
                          height: AppStyles.paddingSmall,
                        ),
                        if (sale.clientPhone != null)
                          Column(
                            children: [
                              _buildDetailRow(
                                'Teléfono:',
                                sale.clientPhone!,
                              ),
                              const SizedBox(
                                height:
                                    AppStyles.paddingSmall,
                              ),
                            ],
                          ),
                        if (sale.clientEmail != null)
                          Column(
                            children: [
                              _buildDetailRow(
                                'Email:',
                                sale.clientEmail!,
                              ),
                              const SizedBox(
                                height:
                                    AppStyles.paddingSmall,
                              ),
                            ],
                          ),
                        _buildDetailRow(
                          'Tipo:',
                          sale.saleType.label,
                        ),
                        const SizedBox(
                          height: AppStyles.paddingSmall,
                        ),
                        _buildDetailRow(
                          'Fecha de Venta:',
                          DateTimeUtils.formatDateWithTime(
                            sale.saleDate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: AppStyles.paddingMedium,
                ),
                Text(
                  'Artículos',
                  style: AppStyles.headlineSmall,
                ),
                const SizedBox(
                  height: AppStyles.paddingSmall,
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: salesProvider
                      .getSaleDetailsWithProductInfo(
                    sale.id,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(
                            AppStyles.paddingMedium,
                          ),
                          child: Center(
                            child: Text(
                              'Sin artículos',
                            ),
                          ),
                        ),
                      );
                    }

                    final items = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom:
                                AppStyles.paddingSmall,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppStyles.paddingMedium,
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['product_name'] ??
                                      'Producto',
                                  style: AppStyles
                                      .labelLarge
                                      .copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: AppStyles
                                      .paddingSmall,
                                ),
                                _buildDetailRow(
                                  'Cantidad:',
                                  item['quantity']
                                      .toString(),
                                ),
                                const SizedBox(
                                  height: AppStyles
                                      .paddingXSmall,
                                ),
                                _buildDetailRow(
                                  'Precio unitario:',
                                  '\$${(item['unit_price'] as num).toStringAsFixed(2)}',
                                ),
                                const SizedBox(
                                  height: AppStyles
                                      .paddingXSmall,
                                ),
                                _buildDetailRow(
                                  'Subtotal:',
                                  '\$${(item['subtotal'] as num).toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: AppStyles.paddingMedium,
                ),
                Card(
                  color:
                      AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(
                      AppStyles.paddingMedium,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style:
                              AppStyles.headlineSmall,
                        ),
                        Text(
                          '\$${sale.totalAmount.toStringAsFixed(2)}',
                          style: AppStyles
                              .headlineSmall
                              .copyWith(
                            color: AppColors.primary,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: AppStyles.paddingMedium,
                ),
                if (sale.status ==
                    SaleStatus.pending)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await salesProvider
                            .updateSaleStatus(
                          sale.id,
                          SaleStatus.completed,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Venta marcada como completada',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.check_circle,
                      ),
                      label: const Text(
                        'Marcar como Completada',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: AppColors
                            .statusCompleted,
                      ),
                    ),
                  ),
                if (sale.status ==
                        SaleStatus.completed ||
                    sale.status ==
                        SaleStatus.cancelled)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppStyles.paddingSmall,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await salesProvider
                              .updateSaleStatus(
                            sale.id,
                            SaleStatus.pending,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Venta reactivada',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(
                          Icons.restore,
                        ),
                        label: const Text(
                          'Reactivar Venta',
                        ),
                      ),
                    ),
                  ),
                if (sale.status !=
                    SaleStatus.cancelled)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppStyles.paddingSmall,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await salesProvider
                              .updateSaleStatus(
                            sale.id,
                            SaleStatus.cancelled,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(
                                    context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Venta cancelada',
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        icon:
                            const Icon(Icons.cancel),
                        label: const Text(
                          'Cancelar Venta',
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors
                                  .statusCancelled,
                        ),
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

  Widget _buildDetailRow(
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.bodySmall,
        ),
        Text(
          value,
          style: AppStyles.labelLarge,
        ),
      ],
    );
  }
}