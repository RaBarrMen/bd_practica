import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale.dart';
import '../../providers/cart_provider.dart';
import '../../providers/categories_provider.dart';
import '../../providers/sales_provider.dart';
import '../../providers/products_provider.dart';
import '../../utils/colors.dart';
import '../../constants/app_styles.dart';
import 'sale_detail_screen.dart';

class CreateSaleScreen extends StatefulWidget {
  const CreateSaleScreen({Key? key}) : super(key: key);

  @override
  State<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _notesController = TextEditingController();
  late final Future<void> _initialLoadFuture;

  SaleType? _selectedSaleType = SaleType.venta;
  bool _reminderEnabled = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initialLoadFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      context.read<ProductsProvider>().loadProducts(),
      context.read<CategoriesProvider>().loadCategories(),
    ]);
    if (mounted) {
      context.read<CartProvider>().clear();
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveSale() async {
    if (_formKey.currentState!.validate()) {
      final cartProvider = context.read<CartProvider>();

      if (_selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
        return;
      }

      if (cartProvider.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes agregar al menos un producto')),
        );
        return;
      }

      // Obtener el provider
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Guardar la venta en BD
        final sale = await salesProvider.createSale(
          clientName: _clientNameController.text,
          saleType: _selectedSaleType ?? SaleType.venta,
          saleDate: _selectedDate!,
          clientPhone: _clientPhoneController.text.isEmpty
              ? null
              : _clientPhoneController.text,
          clientEmail: _clientEmailController.text.isEmpty
              ? null
              : _clientEmailController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          reminderEnabled: _reminderEnabled,
        );

        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          if (sale != null) {
            bool allAdded = true;
            for (final item in cartProvider.items) {
              final success = await salesProvider.addSaleDetail(
                saleId: sale.id,
                productId: item.product.id,
                quantity: item.quantity.toDouble(),
                unitPrice: item.product.price,
              );
              if (!success) {
                allAdded = false;
              }
            }

            await salesProvider.loadSales();
            final updatedSale = salesProvider.getSaleById(sale.id) ?? sale;
            final itemCount = cartProvider.totalItems;
            final total = cartProvider.total;
            cartProvider.clear();

            if (!allAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'La venta fue creada, pero algunos productos no se guardaron',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }

            await showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Venta guardada'),
                content: Text(
                  'Productos: $itemCount\n'
                  'Total calculado: \$${total.toStringAsFixed(2)}',
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            );

            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SaleDetailScreen(sale: updatedSale),
                ),
              );
            }
          } else {
            // Error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${salesProvider.error ?? "No se pudo guardar"}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Venta'), elevation: 0),
      body: FutureBuilder(
        future: _initialLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Tipo de Venta
                const Text(
                  'Tipo de Venta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppStyles.paddingSmall),
                DropdownButtonFormField<SaleType>(
                  value: _selectedSaleType,
                  items: SaleType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSaleType = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Selecciona tipo',
                    prefixIcon: Icon(Icons.category),
                  ),
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Nombre del Cliente
                TextFormField(
                  controller: _clientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Cliente',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Ingresa el nombre',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Teléfono
                TextFormField(
                  controller: _clientPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                    hintText: 'Ingresa el teléfono',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Email
                TextFormField(
                  controller: _clientEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Ingresa el email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Fecha de Venta
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.paddingMedium,
                      vertical: AppStyles.paddingMedium,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.dividerColor),
                      borderRadius: BorderRadius.circular(
                        AppStyles.borderRadiusMedium,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppStyles.paddingMedium),
                        Text(
                          _selectedDate == null
                              ? 'Selecciona fecha'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Recordatorio
                CheckboxListTile(
                  title: const Text('Habilitar recordatorio'),
                  value: _reminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      _reminderEnabled = value ?? false;
                    });
                  },
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Productos y total automático
                Consumer3<CartProvider, ProductsProvider, CategoriesProvider>(
                  builder: (context, cartProvider, _, categoriesProvider, __) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppStyles.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Productos de la Venta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _showAddProductModal,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar Producto'),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppStyles.paddingSmall),
                            if (cartProvider.items.isEmpty)
                              const Text('Sin productos agregados')
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cartProvider.items.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final item = cartProvider.items[index];
                                  final category = categoriesProvider
                                      .getCategoryById(item.product.categoryId);

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: AppStyles.paddingXSmall,
                                      ),
                                      Text(
                                        'Categoría: ${category?.name ?? "Sin categoría"}',
                                        style: AppStyles.bodySmall,
                                      ),
                                      const SizedBox(
                                        height: AppStyles.paddingXSmall,
                                      ),
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 80,
                                            child: TextFormField(
                                              initialValue:
                                                  item.quantity.toString(),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Cant.',
                                                isDense: true,
                                              ),
                                              onFieldSubmitted: (value) {
                                                final quantity = int.tryParse(
                                                  value,
                                                );
                                                if (quantity == null ||
                                                    quantity <= 0 ||
                                                    quantity >
                                                        item.product.stock) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Cantidad inválida para ${item.product.name}',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                cartProvider.updateQuantity(
                                                  item.product.id,
                                                  quantity,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: AppStyles.paddingSmall,
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Unit: \$${item.product.price.toStringAsFixed(2)}  •  Sub: \$${item.subtotal.toStringAsFixed(2)}',
                                              style: AppStyles.bodySmall,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                cartProvider.removeItem(
                                                  item.product.id,
                                                ),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            const SizedBox(height: AppStyles.paddingSmall),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total automático: \$${cartProvider.total.toStringAsFixed(2)}',
                                style: AppStyles.bodyLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Notas
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Ingresa notas adicionales',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppStyles.paddingLarge),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dividerColor,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: AppStyles.paddingMedium),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveSale,
                        child: const Text('Guardar'),
                      ),
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
    );
  }

  void _showAddProductModal() {
    final categoriesProvider = context.read<CategoriesProvider>();
    final productsProvider = context.read<ProductsProvider>();
    final cartProvider = context.read<CartProvider>();
    int? selectedCategoryId;
    final quantityControllers = <int, TextEditingController>{};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final products = productsProvider.products.where((product) {
              return selectedCategoryId == null ||
                  product.categoryId == selectedCategoryId;
            }).toList();

            return AlertDialog(
              title: const Text('Agregar Producto'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int?>(
                      value: selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por categoría',
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ...categoriesProvider.categories.map(
                          (category) => DropdownMenuItem<int?>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppStyles.paddingSmall),
                    SizedBox(
                      height: 320,
                      child: products.isEmpty
                          ? const Center(
                              child: Text('No hay productos en esta categoría'),
                            )
                          : ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                final category = categoriesProvider
                                    .getCategoryById(product.categoryId);
                                final quantityController = quantityControllers
                                    .putIfAbsent(
                                      product.id,
                                      () => TextEditingController(text: '1'),
                                    );

                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      AppStyles.paddingSmall,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: AppStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Categoría: ${category?.name ?? "Sin categoría"}',
                                          style: AppStyles.bodySmall,
                                        ),
                                        if (product.description != null)
                                          Text(
                                            product.description!,
                                            style: AppStyles.bodySmall,
                                          ),
                                        const SizedBox(
                                          height: AppStyles.paddingXSmall,
                                        ),
                                        Text(
                                          'Precio: \$${product.price.toStringAsFixed(2)} • Stock: ${product.stock}',
                                          style: AppStyles.bodySmall,
                                        ),
                                        const SizedBox(
                                          height: AppStyles.paddingSmall,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: TextField(
                                                controller: quantityController,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration:
                                                    const InputDecoration(
                                                      labelText: 'Cant.',
                                                      isDense: true,
                                                    ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppStyles.paddingSmall,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  final quantity =
                                                      int.tryParse(
                                                        quantityController.text,
                                                      );
                                                  if (quantity == null ||
                                                      quantity <= 0) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Cantidad inválida',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  final currentCartQuantity =
                                                      cartProvider
                                                          .getProductQuantity(
                                                            product.id,
                                                          );
                                                  final newTotalQuantity =
                                                      currentCartQuantity +
                                                      quantity;

                                                  if (newTotalQuantity >
                                                      product.stock) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Stock insuficiente para ${product.name}',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  cartProvider.addItem(
                                                    product,
                                                    quantity.toDouble(),
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${product.name} agregado a la venta',
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Agregar a venta',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Listo'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      for (final controller in quantityControllers.values) {
        controller.dispose();
      }
    });
  }
}
