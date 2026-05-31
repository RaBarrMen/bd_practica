import 'package:flutter/material.dart';
import '../../constants/app_styles.dart';
import '../../models/category.dart';
import '../../models/product.dart';

class ProductFormData {
  final int categoryId;
  final String name;
  final double price;
  final String? description;
  final int stock;
  final String? unit;

  const ProductFormData({
    required this.categoryId,
    required this.name,
    required this.price,
    this.description,
    required this.stock,
    this.unit,
  });
}

class ProductFormModal extends StatefulWidget {
  final Product? product;
  final List<Category> categories;
  final Future<bool> Function(ProductFormData data) onSubmit;

  const ProductFormModal({
    Key? key,
    this.product,
    required this.categories,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends State<ProductFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();
  int? _selectedCategoryId;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;

    if (product != null) {
      _selectedCategoryId = product.categoryId;
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(2);
      _descriptionController.text = product.description ?? '';
      _stockController.text = product.stock.toString();
      _unitController.text = product.unit ?? '';
    } else {
      _selectedCategoryId = widget.categories.isNotEmpty ? widget.categories.first.id : null;
      _stockController.text = '0';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    setState(() {
      _isSaving = true;
    });

    final success = await widget.onSubmit(
      ProductFormData(
        categoryId: _selectedCategoryId!,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        stock: int.parse(_stockController.text.trim()),
        unit: _unitController.text.trim().isEmpty ? null : _unitController.text.trim(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Editar producto' : 'Nuevo producto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: widget.categories
                    .map(
                      (category) => DropdownMenuItem<int>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                validator: (value) => value == null ? 'Selecciona una categoría' : null,
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const SizedBox(height: AppStyles.paddingMedium),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre del producto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppStyles.paddingMedium),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppStyles.paddingMedium),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppStyles.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        prefixIcon: Icon(Icons.production_quantity_limits_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse((value ?? '').trim());
                        if (parsed == null || parsed < 0) {
                          return 'Stock inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppStyles.paddingMedium),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
