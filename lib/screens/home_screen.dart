import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/sales_provider.dart';
import '../providers/cart_provider.dart';
import '../constants/app_styles.dart';
import '../utils/colors.dart';
import 'calendar/calendar_screen.dart';
import 'sales/sales_list_screen.dart';
import 'cart/cart_screen.dart';
import 'sales/create_sale_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [SalesListScreen(), CalendarScreen()];

  @override
  void initState() {
    super.initState();
    // Cargar datos al iniciar
    Future.microtask(() {
      context.read<SalesProvider>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas & Servicios', style: AppStyles.headlineSmall),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/products-management');
            },
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Gestionar productos',
          ),
          // Badge con contador de carrito
          Padding(
            padding: const EdgeInsets.all(AppStyles.paddingMedium),
            child: Consumer<CartProvider>(
              builder: (context, cart, _) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: badges.Badge(
                    badgeContent: Text(
                      cart.itemCount.toString(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    showBadge: cart.itemCount > 0,
                    badgeStyle: const badges.BadgeStyle(
                      badgeColor: AppColors.secondary,
                      padding: EdgeInsets.all(6),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.cardColor,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Listado'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSaleScreen()),
          );

          // Si volvemos de crear venta, recargar lista
          if (result == true && mounted) {
            context.read<SalesProvider>().loadSales();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
