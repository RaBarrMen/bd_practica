class DateTimeUtils {
  // Obtener el nombre del mes
  static String getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month - 1];
  }

  // Obtener el nombre del día
  static String getDayName(int weekday) {
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return days[weekday - 1];
  }

  // Formato: "15 de Enero de 2026"
  static String formatLongDate(DateTime date) {
    return '${date.day} de ${getMonthName(date.month)} de ${date.year}';
  }

  // Formato: "15/01/2026"
  static String formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Formato: "15/01/2026 14:30"
  static String formatDateWithTime(DateTime date) {
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '${formatShortDate(date)} $time';
  }

  // Solo hora: "14:30"
  static String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Verificar si es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Verificar si es mañana
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Obtener fecha con texto relativo
  static String getRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Hoy';
    } else if (isTomorrow(date)) {
      return 'Mañana';
    } else if (date.isBefore(DateTime.now())) {
      return 'Hace ${DateTime.now().difference(date).inDays} días';
    } else {
      return 'En ${date.difference(DateTime.now()).inDays} días';
    }
  }

  // Obtener inicio del día
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Obtener fin del día
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  // Restar 2 días
  static DateTime subtract2Days(DateTime date) {
    return date.subtract(Duration(days: 2));
  }
}