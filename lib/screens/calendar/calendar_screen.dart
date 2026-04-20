import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/sales_provider.dart';
import '../../models/sale.dart';
import '../../utils/colors.dart';
import '../../constants/app_styles.dart';
import '../../widgets/status_indicator.dart';
import '../../utils/date_utils.dart';
import 'day_modal.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;

    // Cargar ventas
    Future.microtask(() {
      context.read<SalesProvider>().loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppStyles.paddingMedium),
          child: Column(
            children: [
              // Calendario
              Card(
                elevation: AppStyles.elevationSmall,
                child: TableCalendar<Sale>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    // Mostrar modal con eventos del día
                    final salesOfDay =
                        salesProvider.getSalesByDate(selectedDay);
                    if (salesOfDay.isNotEmpty) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => DayModal(
                          date: selectedDay,
                          sales: salesOfDay,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hay ventas para este día'),
                        ),
                      );
                    }
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  // Dots bajo los números de días
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final salesOfDay =
                          salesProvider.getSalesByDate(day);

                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: Text(
                                day.day.toString(),
                                style: AppStyles.bodyMedium,
                              ),
                            ),
                            if (salesOfDay.isNotEmpty)
                              Positioned(
                                bottom: 4,
                                child: Wrap(
                                  spacing: 2,
                                  children: salesOfDay.take(3).map((sale) {
                                    return StatusIndicator(
                                      status: sale.status,
                                      size: 6,
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final salesOfDay =
                          salesProvider.getSalesByDate(day);

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: Text(
                                day.day.toString(),
                                style: AppStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (salesOfDay.isNotEmpty)
                              Positioned(
                                bottom: 4,
                                child: Wrap(
                                  spacing: 2,
                                  children: salesOfDay.take(3).map((sale) {
                                    return StatusIndicator(
                                      status: sale.status,
                                      size: 6,
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final salesOfDay =
                          salesProvider.getSalesByDate(day);

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: Text(
                                day.day.toString(),
                                style: AppStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (salesOfDay.isNotEmpty)
                              Positioned(
                                bottom: 4,
                                child: Wrap(
                                  spacing: 2,
                                  children: salesOfDay.take(3).map((sale) {
                                    return StatusIndicator(
                                      status: sale.status,
                                      size: 6,
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppStyles.borderRadiusSmall),
                      ),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: AppColors.white,
                    ),
                    titleTextStyle: AppStyles.headlineSmall,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: AppStyles.labelMedium,
                    weekendStyle: AppStyles.labelMedium,
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.paddingLarge),
              // Leyenda de colores
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leyenda de Estados',
                        style: AppStyles.headlineSmall,
                      ),
                      const SizedBox(height: AppStyles.paddingMedium),
                      _buildLegendItem(
                        SaleStatus.pending,
                        'En Proceso',
                      ),
                      const SizedBox(height: AppStyles.paddingSmall),
                      _buildLegendItem(
                        SaleStatus.completed,
                        'Completado',
                      ),
                      const SizedBox(height: AppStyles.paddingSmall),
                      _buildLegendItem(
                        SaleStatus.cancelled,
                        'Cancelado',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.paddingMedium),
              // Resumen del día seleccionado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Día Seleccionado: ${DateTimeUtils.formatLongDate(_selectedDay)}',
                        style: AppStyles.headlineSmall,
                      ),
                      const SizedBox(height: AppStyles.paddingMedium),
                      Text(
                        'Ventas: ${salesProvider.getSalesByDate(_selectedDay).length}',
                        style: AppStyles.bodyLarge,
                      ),
                      const SizedBox(height: AppStyles.paddingSmall),
                      Text(
                        'Total: \$${_calculateTotal(salesProvider.getSalesByDate(_selectedDay)).toStringAsFixed(2)}',
                        style: AppStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(SaleStatus status, String label) {
    return Row(
      children: [
        StatusIndicator(status: status, size: 16),
        const SizedBox(width: AppStyles.paddingMedium),
        Text(label, style: AppStyles.bodyMedium),
      ],
    );
  }

  double _calculateTotal(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.totalAmount);
  }
}