class Validators {
  // Validar nombre
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    return null;
  }

  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email es opcional
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  // Validar teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Teléfono es opcional
    }
    if (value.length < 7) {
      return 'El teléfono debe tener al menos 7 dígitos';
    }
    if (value.length > 20) {
      return 'El teléfono no puede exceder 20 caracteres';
    }
    return null;
  }

  // Validar cantidad
  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es requerida';
    }
    try {
      final quantity = double.parse(value);
      if (quantity <= 0) {
        return 'La cantidad debe ser mayor a 0';
      }
      return null;
    } catch (e) {
      return 'Ingresa una cantidad válida';
    }
  }

  // Validar precio
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es requerido';
    }
    try {
      final price = double.parse(value);
      if (price < 0) {
        return 'El precio no puede ser negativo';
      }
      return null;
    } catch (e) {
      return 'Ingresa un precio válido';
    }
  }

  // Validar no vacío
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }
}