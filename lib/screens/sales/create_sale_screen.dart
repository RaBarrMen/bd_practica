import 'package:flutter/material.dart';

class CreateSaleScreen extends StatefulWidget {
  const CreateSaleScreen({Key? key}) : super(key: key);

  @override
  State<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends State<CreateSaleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Venta'),
      ),
      body: const Center(
        child: Text('Crear Venta - En desarrollo'),
      ),
    );
  }
}