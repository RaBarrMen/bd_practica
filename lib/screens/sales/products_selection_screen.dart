import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/colors.dart';
import '../../constants/app_styles.dart';
import '../../utils/validators.dart';
import 'sale_detail_screen.dart';

class ProductsSelectionScreen extends StatefulWidget {
  final int saleId;
  final int categoryId;
  final String categoryName;

  const ProductsSelectionScreen({
    Key? key,
    required this.saleId,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ProductsSelectionScreen> createState() =>
      _ProductsSelectionScreenState();
}

class _ProductsSelectionScreenState extends State<ProductsSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context
          .read<ProductsProvider>()
          .filterByCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos - ${widget.categoryName}'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, productsProvider, _) {
          if (productsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productsProvider.products.isEmpty) {
            return const Center(
              child: Text('No hay productos en esta categoría'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            itemCount: productsProvider.products.length,
            itemBuilder: (context, index) {
              final product = productsProvider.products[index];
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppStyles.paddingMedium,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppStyles.labelLarge,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: AppStyles.paddingXSmall,
                                  ),
                                  if (product.description != null)
                                    Text(
                                      product.description!,
                                      style: AppStyles.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(
                                    height: AppStyles.paddingSmall,
                                  ),
                                  Text(
                                    'Precio: \$${product.price.toStringAsFixed(2)}',
                                    style: AppStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product.stock > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppStyles.paddingXSmall,
                                      ),
                                      child: Text(
                                        'Stock: ${product.stock} ${product.unit ?? 'uds'}',
                                        style: AppStyles.bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppStyles.paddingMedium),
                            ElevatedButton.icon(
                              onPressed: () {
                                _showQuantityDialog(context, product);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final cartProvider = context.read<CartProvider>();
          if (cartProvider.items.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debes agregar al menos un producto'),
              ),
            );
            return;
          }

          // Agregar los detalles de la venta
          _saveSaleDetails(context, cartProvider);
        },
        icon: const Icon(Icons.check),
        label: const Text('Terminar Venta'),
        backgroundColor: AppColors.statusCompleted,
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, dynamic product) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Precio: \$${product.price.toStringAsFixed(2)}',
              style: AppStyles.labelLarge,
            ),
            const SizedBox(height: AppStyles.paddingMedium),
            TextField(
              controller: quantityController,
              decoration: AppStyles.textFieldDecoration('Cantidad'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text) ?? 0;
              if (quantity > 0) {
                context.read<CartProvider>().addItem(product, quantity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${product.name} agregado al carrito',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa una cantidad válida'),
                  ),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSaleDetails(
    BuildContext context,
    CartProvider cartProvider,
  ) async {
    final salesProvider = context.read<SalesProvider>();
    final sale = salesProvider.getSaleById(widget.saleId);

    if (sale == null) return;

    bool allAdded = true;
    for (var item in cartProvider.items) {
      final success = await salesProvider.addSaleDetail(
        saleId: widget.saleId,
        productId: item.product.id,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
      );

      if (!success) {
        allAdded = false;
      }
    }

    if (allAdded) {
      cartProvider.clear();
      
      if (mounted) {
        // Navegar al detalle de la venta
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SaleDetailScreen(sale: sale),
          ),
          (route) => route.isFirst,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar algunos artículos'),
        ),
      );
    }
  }
}