import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/categories_provider.dart';
import 'providers/products_provider.dart';
import 'providers/sales_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'utils/colors.dart';
import 'constants/app_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => SalesProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Ventas & Servicios',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
          ),
          scaffoldBackgroundColor: AppColors.backgroundColor,
          cardTheme: CardTheme(
            color: AppColors.cardColor,
            elevation: AppStyles.elevationSmall,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
              borderSide: const BorderSide(color: AppColors.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
              borderSide: const BorderSide(color: AppColors.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppStyles.paddingMedium,
              vertical: AppStyles.paddingMedium,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}