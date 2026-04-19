import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../constants/app_styles.dart';
import '../../utils/colors.dart';
import '../../widgets/status_badge.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(
              child: Text('El carrito está vacío'),
            );
          }

          return Column(
            children: [
              // Lista de items
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppStyles.paddingMedium,
                        vertical: AppStyles.paddingSmall,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppStyles.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.product.name,
                                      style: AppStyles.labelLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: AppColors.statusCancelled),
                                    onPressed: () {
                                      cart.removeItem(item.product.id);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppStyles.paddingSmall),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Precio: \$${item.unitPrice.toStringAsFixed(2)}',
                                    style: AppStyles.bodySmall,
                                  ),
                                  Text(
                                    'Cantidad: ${item.quantity}',
                                    style: AppStyles.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppStyles.paddingSmall),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                                    style: AppStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            cart.updateQuantity(
                                              item.product.id,
                                              item.quantity - 1,
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: TextField(
                                          textAlign: TextAlign.center,
                                          controller: TextEditingController(
                                            text:
                                                item.quantity.toStringAsFixed(0),
                                          ),
                                          onChanged: (value) {
                                            final newQuantity =
                                                double.tryParse(value) ?? 0;
                                            if (newQuantity > 0) {
                                              cart.updateQuantity(
                                                item.product.id,
                                                newQuantity,
                                              );
                                            }
                                          },
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          cart.updateQuantity(
                                            item.product.id,
                                            item.quantity + 1,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total y botones
              Container(
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  boxShadow: [AppStyles.shadowMedium],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: AppStyles.headlineSmall,
                        ),
                        Text(
                          '\$${cart.totalPrice.toStringAsFixed(2)}',
                          style: AppStyles.headlineSmall.copyWith(
                            color: AppColors.statusCompleted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              cart.clear();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greyLight,
                              foregroundColor: AppColors.textPrimary,
                            ),
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: AppStyles.paddingMedium),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Compra realizada exitosamente'),
                                ),
                              );
                              cart.clear();
                              Navigator.pop(context);
                            },
                            child: const Text('Proceder al Pago'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}