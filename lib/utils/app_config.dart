/// Configuración central de la aplicación
class AppConfig {
  // URLs predeterminadas para acciones
  static const String defaultWebUrl = 'https://www.google.com';

  // Umbrales de detección
  static const double movementThreshold = 2.0;
  static const double actionCooldown = 2.0; // segundos

  // Acciones configurables
  static const Map<String, String> actionNames = {
    'office': 'Abrir Office',
    'web': 'Abrir Navegador',
    'media': 'Reproducir Media',
  };

  // URLs configurables
  static const Map<String, String> actionUrls = {
    'office': '', // Se ejecuta localmente
    'web': defaultWebUrl,
    'media': '', // Se ejecuta localmente
  };
}
