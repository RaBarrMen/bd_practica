import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sale.dart';
import '../../providers/sales_provider.dart';
import '../../providers/products_provider.dart';
import '../../utils/colors.dart';
import '../../constants/app_styles.dart';

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
  final _totalAmountController = TextEditingController();

  SaleType? _selectedSaleType = SaleType.venta;
  SaleStatus? _selectedStatus = SaleStatus.pending;
  bool _reminderEnabled = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _notesController.dispose();
    _totalAmountController.dispose();
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
      if (_selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Selecciona una fecha')));
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
          Navigator.pop(context); // Cerrar loading

          if (sale != null) {
            // Éxito
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✓ Venta guardada exitosamente'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            // Volver a la pantalla anterior después de 1 segundo
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
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
          Navigator.pop(context); // Cerrar loading
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
      body: SingleChildScrollView(
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

                // Monto Total
                TextFormField(
                  controller: _totalAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Monto Total',
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: '0.00',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'El monto es requerido';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppStyles.paddingMedium),

                // Estado
                const Text(
                  'Estado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppStyles.paddingSmall),
                DropdownButtonFormField<SaleStatus>(
                  value: _selectedStatus,
                  items: SaleStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Selecciona estado',
                    prefixIcon: Icon(Icons.info),
                  ),
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
      ),
    );
  }
}
