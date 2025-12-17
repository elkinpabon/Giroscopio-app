import 'package:sensors_plus/sensors_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/gyroscope_data.dart';
import '../utils/action_service.dart';

class GyroscopeController extends GetxController {
  // Variables reactivas
  final RxList<GyroscopeData> gyroscopeHistory = <GyroscopeData>[].obs;
  final Rx<GyroscopeData?> currentReading = Rx<GyroscopeData?>(null);
  final RxString lastAction = RxString('');
  final RxBool isMonitoring = RxBool(false);

  // Variables de conexión
  final RxBool isConnected = RxBool(false);
  final RxString connectionStatus = RxString('Verificando...');
  final RxString lastConnectionCheck = RxString('Nunca');
  final RxInt connectionAttempts = RxInt(0);

  // Umbrales de movimiento mejorados (en radianes/segundo)
  static const double movementThreshold =
      3.5; // Mayor umbral para evitar falsos positivos
  static const double actionCooldown = 2.5; // segundos
  static const double isolationThreshold =
      0.8; // Máximo valor permitido en otros ejes

  // Backend URL
  static const String backendUrl = 'http://192.168.1.54:5000/api';

  double lastActionTime = 0;
  List<double> xHistory = [];
  List<double> yHistory = [];
  List<double> zHistory = [];
  static const int historySize = 5;

  @override
  void onInit() {
    super.onInit();
    // Iniciar verificación de conexión
    startConnectionMonitoring();

    // Solo inicia monitoreo en plataformas móviles
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      startMonitoring();
    } else {
      lastAction.value = 'ℹ️ El giroscopio solo funciona en Android/iOS';
    }
  }

  @override
  void onClose() {
    stopMonitoring();
    super.onClose();
  }

  /// Inicia el monitoreo del giroscopio
  void startMonitoring() {
    // Verificar si la plataforma soporta giroscopio
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      lastAction.value = 'ℹ️ El giroscopio solo funciona en Android/iOS';
      return;
    }

    isMonitoring.value = true;

    try {
      gyroscopeEvents.listen((GyroscopeEvent event) {
        final now = DateTime.now();
        final data = GyroscopeData(
          x: event.x,
          y: event.y,
          z: event.z,
          timestamp: now,
        );

        currentReading.value = data;

        // Mantener historial de los últimos 20 registros
        gyroscopeHistory.add(data);
        if (gyroscopeHistory.length > 20) {
          gyroscopeHistory.removeAt(0);
        }

        // Detectar movimiento significativo
        detectMotionAndExecuteAction(data);
      });
    } catch (e) {
      lastAction.value = 'ℹ️ Error: No se puede acceder al giroscopio';
      isMonitoring.value = false;
    }
  }

  /// Detiene el monitoreo del giroscopio
  void stopMonitoring() {
    isMonitoring.value = false;
  }

  /// Detecta movimiento y ejecuta la acción correspondiente
  void detectMotionAndExecuteAction(GyroscopeData data) {
    final now = DateTime.now().millisecondsSinceEpoch / 1000;

    // Verificar cooldown para evitar múltiples acciones
    if (now - lastActionTime < actionCooldown) {
      return;
    }

    // Mantener historial de valores para análisis
    xHistory.add(data.x);
    yHistory.add(data.y);
    zHistory.add(data.z);

    if (xHistory.length > historySize) xHistory.removeAt(0);
    if (yHistory.length > historySize) yHistory.removeAt(0);
    if (zHistory.length > historySize) zHistory.removeAt(0);

    // Solo procesar si tenemos suficientes datos
    if (xHistory.length < historySize) return;

    // Calcular promedio para suavizar lecturas
    final avgX = xHistory.reduce((a, b) => a + b) / xHistory.length;
    final avgY = yHistory.reduce((a, b) => a + b) / yHistory.length;
    final avgZ = zHistory.reduce((a, b) => a + b) / zHistory.length;

    final absX = avgX.abs();
    final absY = avgY.abs();
    final absZ = avgZ.abs();

    // Detectar el eje con mayor valor
    if (absX > absY && absX > absZ) {
      // Eje X dominante
      if (absX > movementThreshold &&
          absY < isolationThreshold &&
          absZ < isolationThreshold) {
        _executeAction('Office', () => _callBackend('office'));
        lastActionTime = now;
        print('✓ Movimiento X detectado: Office');
      }
    } else if (absY > absX && absY > absZ) {
      // Eje Y dominante
      if (absY > movementThreshold &&
          absX < isolationThreshold &&
          absZ < isolationThreshold) {
        _executeAction('Navegador', () => _callBackend('web'));
        lastActionTime = now;
        print('✓ Movimiento Y detectado: Navegador');
      }
    } else if (absZ > absX && absZ > absY) {
      // Eje Z dominante
      if (absZ > movementThreshold &&
          absX < isolationThreshold &&
          absY < isolationThreshold) {
        _executeAction('Media Player', () => _callBackend('media'));
        lastActionTime = now;
        print('✓ Movimiento Z detectado: Media Player');
      }
    }
  }

  /// Llama al backend para ejecutar acción
  Future<void> _callBackend(String action) async {
    try {
      final response = await http
          .post(
            Uri.parse('$backendUrl/actions/execute'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'action': action,
              'url': action == 'web' ? 'https://www.google.com' : null,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✓ Backend respondió correctamente');
      } else {
        print('⚠️ Backend respondió con código ${response.statusCode}');
      }
    } catch (e) {
      print('✓ Acción enviada (sin conexión backend, usando local)');
      // Fallback: ejecutar localmente si no hay backend
      if (action == 'office') {
        await ActionService.openOffice();
      } else if (action == 'web') {
        await ActionService.openWebpage('https://www.google.com');
      } else if (action == 'media') {
        await ActionService.openMediaPlayer();
      }
    }
  }

  /// Ejecuta una acción y registra el resultado
  void _executeAction(String actionName, Future<void> Function() action) {
    try {
      action()
          .then((_) {
            lastAction.value =
                '✓ $actionName abierto - ${DateTime.now().toLocal()}';
            print('Acción ejecutada: $actionName');
          })
          .catchError((error) {
            lastAction.value = '✗ Error al abrir $actionName';
            print('Error en acción: $error');
          });
    } catch (e) {
      lastAction.value = '✗ Error: $e';
      print('Error ejecutando acción: $e');
    }
  }

  /// Obtiene el eje con mayor actividad
  String getActiveAxis() {
    if (currentReading.value == null) return 'N/A';

    final data = currentReading.value!;
    final absX = data.x.abs();
    final absY = data.y.abs();
    final absZ = data.z.abs();

    if (absX > absY && absX > absZ) return 'X (Office)';
    if (absY > absX && absY > absZ) return 'Y (Web)';
    if (absZ > absX && absZ > absY) return 'Z (Media)';

    return 'Neutro';
  }

  /// Limpia el historial
  void clearHistory() {
    gyroscopeHistory.clear();
    lastAction.value = '';
  }

  /// Verifica la conexión con el backend
  Future<bool> testConnection() async {
    try {
      connectionStatus.value = 'Probando...';
      connectionAttempts.value++;

      final response = await http
          .get(
            Uri.parse('$backendUrl/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        isConnected.value = true;
        connectionStatus.value = '✅ Conectado';
        lastConnectionCheck.value = DateTime.now().toString().split('.')[0];
        return true;
      } else {
        isConnected.value = false;
        connectionStatus.value = '❌ Error ${response.statusCode}';
        lastConnectionCheck.value = DateTime.now().toString().split('.')[0];
        return false;
      }
    } on TimeoutException {
      isConnected.value = false;
      connectionStatus.value = '⏱️ Tiempo agotado';
      lastConnectionCheck.value = DateTime.now().toString().split('.')[0];
      return false;
    } catch (e) {
      isConnected.value = false;
      connectionStatus.value = '❌ No disponible';
      lastConnectionCheck.value = DateTime.now().toString().split('.')[0];
      return false;
    }
  }

  /// Inicia verificación automática de conexión cada 10 segundos
  void startConnectionMonitoring() {
    testConnection();
    Timer.periodic(const Duration(seconds: 10), (_) {
      if (isMonitoring.value) {
        testConnection();
      }
    });
  }
}
