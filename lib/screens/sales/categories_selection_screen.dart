import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/categories_provider.dart';
import '../../utils/colors.dart';
import '../../constants/app_styles.dart';
import 'products_selection_screen.dart';

class CategoriesSelectionScreen extends StatefulWidget {
  final int saleId;

  const CategoriesSelectionScreen({
    Key? key,
    required this.saleId,
  }) : super(key: key);

  @override
  State<CategoriesSelectionScreen> createState() =>
      _CategoriesSelectionScreenState();
}

class _CategoriesSelectionScreenState extends State<CategoriesSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoriesProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Categoría'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<CategoriesProvider>(
        builder: (context, categoriesProvider, _) {
          if (categoriesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (categoriesProvider.categories.isEmpty) {
            return const Center(
              child: Text('No hay categorías disponibles'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: AppStyles.paddingMedium,
              crossAxisSpacing: AppStyles.paddingMedium,
            ),
            itemCount: categoriesProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoriesProvider.categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductsSelectionScreen(
                        saleId: widget.saleId,
                        categoryId: category.id,
                        categoryName: category.name,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: AppStyles.elevationMedium,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.icon ?? '📦',
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: AppStyles.paddingMedium),
                      Text(
                        category.name,
                        textAlign: TextAlign.center,
                        style: AppStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (category.description != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppStyles.paddingSmall,
                          ),
                          child: Text(
                            category.description!,
                            textAlign: TextAlign.center,
                            style: AppStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}