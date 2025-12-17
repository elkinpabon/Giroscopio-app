/// Extensiones útiles para la aplicación

/// Extensión para formatear números a 2 decimales
extension NumExtension on double {
  String toTwoDecimals() => toStringAsFixed(2);

  String toThreeDecimals() => toStringAsFixed(3);

  /// Determina si el valor representa movimiento significativo
  bool isSignificantMovement(double threshold) => abs() > threshold;
}

/// Extensión para DateTime
extension DateTimeExtension on DateTime {
  /// Retorna hora en formato HH:mm:ss
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  /// Retorna hora con milisegundos
  String toTimeStringWithMs() {
    return '${toTimeString()}.${millisecond.toString().padLeft(3, '0')}';
  }
}

/// Extensión para String
extension StringExtension on String {
  /// Capitaliza la primera letra
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Verifica si contiene números
  bool containsNumbers() {
    return RegExp(r'\d').hasMatch(this);
  }
}

/// Extensión para List
extension ListExtension<T> on List<T> {
  /// Obtiene el último elemento o null
  T? getLastOrNull() {
    return isEmpty ? null : last;
  }

  /// Obtiene los últimos N elementos
  List<T> getLastN(int n) {
    if (length <= n) return this;
    return sublist(length - n);
  }
}
