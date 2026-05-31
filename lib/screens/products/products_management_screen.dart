import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_styles.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/categories_provider.dart';
import '../../providers/products_provider.dart';
import '../../utils/colors.dart';
import 'product_form_modal.dart';

class ProductsManagementScreen extends StatefulWidget {
  const ProductsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductsManagementScreen> createState() => _ProductsManagementScreenState();
}

class _ProductsManagementScreenState extends State<ProductsManagementScreen> {
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<CategoriesProvider>().loadCategories();
      await context.read<ProductsProvider>().loadProducts();
    });
  }

  Future<void> _openProductForm({
    Product? product,
    required ProductsProvider productsProvider,
    required List<Category> categories,
  }) async {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes crear una categoría primero')),
      );
      return;
    }

    final createdOrUpdated = await showDialog<bool>(
      context: context,
      builder: (_) => ProductFormModal(
        product: product,
        categories: categories,
        onSubmit: (data) async {
          if (product == null) {
            return productsProvider.createProduct(
              data.categoryId,
              data.name,
              data.price,
              description: data.description,
              stock: data.stock,
              unit: data.unit,
            );
          }

          return productsProvider.updateProduct(
            product.id,
            data.categoryId,
            data.name,
            data.price,
            description: data.description,
            stock: data.stock,
            unit: data.unit,
          );
        },
      ),
    );

    if (!mounted || createdOrUpdated != true) return;
    await productsProvider.loadProducts();

    if (_selectedCategoryId != null) {
      await productsProvider.filterByCategory(_selectedCategoryId!);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          product == null ? 'Producto creado correctamente' : 'Producto actualizado correctamente',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    Product product,
    ProductsProvider productsProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que deseas eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusCancelled),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await productsProvider.deleteProduct(product.id);
    if (!mounted) return;

    if (success) {
      if (_selectedCategoryId != null) {
        await productsProvider.filterByCategory(_selectedCategoryId!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(productsProvider.error ?? 'No se pudo eliminar el producto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductsProvider, CategoriesProvider>(
      builder: (context, productsProvider, categoriesProvider, _) {
        final categories = categoriesProvider.categories;
        final products = productsProvider.products;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Gestión de Productos'),
            backgroundColor: AppColors.primary,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openProductForm(
              productsProvider: productsProvider,
              categories: categories,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo producto'),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppStyles.paddingMedium),
                child: DropdownButtonFormField<int?>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por categoría',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todas las categorías'),
                    ),
                    ...categories.map(
                      (category) => DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: (value) async {
                    setState(() {
                      _selectedCategoryId = value;
                    });

                    if (value == null) {
                      await productsProvider.loadProducts();
                    } else {
                      await productsProvider.filterByCategory(value);
                    }
                  },
                ),
              ),
              Expanded(
                child: productsProvider.isLoading || categoriesProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : products.isEmpty
                        ? const Center(child: Text('No hay productos registrados'))
                        : ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppStyles.paddingMedium,
                            ),
                            children: _buildProductsByCategory(
                              products: products,
                              categories: categories,
                              productsProvider: productsProvider,
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildProductsByCategory({
    required List<Product> products,
    required List<Category> categories,
    required ProductsProvider productsProvider,
  }) {
    final categoryMap = <int, Category>{for (final c in categories) c.id: c};
    final productsByCategory = <int, List<Product>>{};

    for (final product in products) {
      productsByCategory.putIfAbsent(product.categoryId, () => []).add(product);
    }

    final sortedCategoryIds = productsByCategory.keys.toList()
      ..sort((a, b) {
        final nameA = categoryMap[a]?.name ?? '';
        final nameB = categoryMap[b]?.name ?? '';
        return nameA.compareTo(nameB);
      });

    return [
      for (final categoryId in sortedCategoryIds) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: AppStyles.paddingSmall, top: AppStyles.paddingSmall),
          child: Text(
            categoryMap[categoryId]?.name ?? 'Sin categoría',
            style: AppStyles.headlineSmall,
          ),
        ),
        ...productsByCategory[categoryId]!.map(
          (product) => Card(
            margin: const EdgeInsets.only(bottom: AppStyles.paddingSmall),
            child: ListTile(
              title: Text(product.name, style: AppStyles.labelLarge),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.description != null && product.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppStyles.paddingXSmall),
                      child: Text(product.description!),
                    ),
                  const SizedBox(height: AppStyles.paddingXSmall),
                  Text(
                    'Precio: \$${product.price.toStringAsFixed(2)} • Stock: ${product.stock} ${product.unit ?? 'pcs'}',
                    style: AppStyles.bodySmall,
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _openProductForm(
                      product: product,
                      productsProvider: productsProvider,
                      categories: categories,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.statusCancelled),
                    onPressed: () => _confirmDelete(product, productsProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppStyles.paddingSmall),
      ],
      const SizedBox(height: 80),
    ];
  }
}
