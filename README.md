# Giroscopio App - Control por Gestos

Una aplicación Flutter innovadora que utiliza el sensor giroscopio del dispositivo móvil para detectar movimientos y ejecutar acciones como abrir Office, navegador web o reproductor multimedia. La app incluye un backend Python Flask para manejo centralizado de acciones.

## 📱 Descripción General

**Giroscopio App** es una solución completa que permite controlar aplicaciones del equipo (Office, navegador, media player) mediante movimientos simples detectados a través del giroscopio del teléfono:

- **Eje X**: Abre Microsoft Office
- **Eje Y**: Abre el navegador web
- **Eje Z**: Abre el reproductor multimedia

La aplicación incluye un sistema inteligente de detección de movimientos con umbrales configurables y un backend para ejecutar acciones de forma centralizada.

---

## 🎯 Características Principales

### 📊 Monitoreo en Tiempo Real
- Captura continua de datos del giroscopio (eje X, Y, Z)
- Visualización de lecturas en radianes/segundo
- Historial de las últimas 20 lecturas
- Indicadores visuales de actividad con barras de progreso

### 🎬 Detección Inteligente de Movimientos
- Algoritmo de suavizado con análisis de historial (últimos 5 datos)
- Umbrales configurables por eje para evitar falsos positivos
- Sistema de cooldown entre acciones (2.5 segundos)
- Aislamiento de ejes para detectar movimientos específicos

### 🌐 Integración Backend
- Backend Flask en Python en puerto 5000
- Verificación de estado de conexión (health check)
- Ejecución de acciones remota o local con fallback automático
- Monitoreo automático de conexión cada 10 segundos
- Estadísticas de acciones ejecutadas

### 🎨 Interfaz de Usuario
- Diseño Material 3 con paleta de colores profundos
- Estado de conexión en tiempo real
- Botones de control (Iniciar, Pausar, Limpiar)
- Información visual de ejes activos
- Historial de acciones ejecutadas
- Soporte responsivo en múltiples plataformas

### 🔧 Compatibilidad Multiplataforma
- ✅ Android
- ✅ iOS
- ✅ Windows (ejecuta acciones locales)
- ⚠️ Web (solo lectura de sensores, no soportado)

---

## 🛠️ Arquitectura Técnica

### Frontend (Flutter)
```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── controllers/
│   └── gyroscope_controller.dart  # Lógica de monitoreo y detección
├── models/
│   └── gyroscope_data.dart   # Modelo de datos del giroscopio
├── views/
│   └── gyroscope_view.dart   # UI principal
└── utils/
    ├── action_service.dart   # Servicio para ejecutar acciones
    ├── app_config.dart       # Configuración centralizada
    ├── constants.dart        # Constantes de la app
    ├── custom_widgets.dart   # Widgets personalizados
    └── extensions.dart       # Extensiones de Dart
```

### Backend (Python Flask)
```
backend/
├── run.py                    # Script de inicio del servidor
├── requirements.txt          # Dependencias Python
└── app/
    ├── __init__.py          # Factory de Flask
    ├── config/
    │   └── settings.py      # Configuración del backend
    ├── routes/
    │   └── api.py           # Rutas API con estadísticas
    ├── actions/
    │   └── executor.py      # Ejecutor de acciones
    └── utils/
        └── connection.py    # Utilidades de conexión
```

---

## 📦 Dependencias

### Frontend (Flutter)
```yaml
dependencies:
  flutter:
    sdk: ^3.9.2
  sensors_plus: ^7.0.0        # Acceso a sensores (giroscopio)
  url_launcher: ^6.2.0        # Lanzar URLs y aplicaciones
  get: ^4.6.6                 # State management (GetX)
  http: ^1.1.0                # Llamadas HTTP al backend
  cupertino_icons: ^1.0.8     # Iconos iOS
```

### Backend (Python)
```
Flask==3.0.0                  # Framework web
flask-cors==4.0.0             # CORS para conexiones remotas
Werkzeug==3.0.1               # Utilidades de servidor
```

---

## 🚀 Instalación y Configuración

### Requisitos Previos
- Flutter SDK (^3.9.2)
- Python 3.8+
- Android SDK o Xcode (según plataforma)
- IDE: VS Code, Android Studio o XCode

### Paso 1: Clonar el Proyecto
```bash
git clone <repository>
cd giroscopio_app
```

### Paso 2: Configurar Frontend (Flutter)
```bash
# Instalar dependencias
flutter pub get

# Ver dispositivos conectados
flutter devices

# Ejecutar en dispositivo
flutter run
```

### Paso 3: Configurar Backend (Python)
```bash
# Navegar a carpeta backend
cd backend

# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar servidor
python run.py
```

### Paso 4: Configurar IP del Backend
1. Identificar la IP local del equipo (backend):
   ```bash
   # Windows
   ipconfig
   # macOS/Linux
   ifconfig
   ```

2. Modificar la IP en lib/controllers/gyroscope_controller.dart:
   ```dart
   static const String backendUrl = 'http://192.168.1.54:5000/api';  // Cambiar IP
   ```

3. Recompilar la aplicación:
   ```bash
   flutter run
   ```

---

## 📐 Algoritmo de Detección de Movimientos

### Parámetros de Configuración
```dart
static const double movementThreshold = 3.5;      // Umbral mínimo (rad/s)
static const double actionCooldown = 2.5;         // Espera entre acciones (s)
static const double isolationThreshold = 0.8;     // Máx valor otros ejes
static const int historySize = 5;                 // Muestras para suavizado
```

### Flujo de Detección

1. **Captura de datos**: Lee giroscopio continuamente
2. **Almacenamiento**: Guarda últimas 5 lecturas por eje
3. **Suavizado**: Calcula promedio móvil
4. **Detección de eje dominante**: Identifica eje con mayor valor
5. **Validación de aislamiento**: Verifica que otros ejes están bajos
6. **Ejecución de acción**: Si supera umbral y pasa validaciones
7. **Cooldown**: Espera 2.5s antes de detectar otra acción

### Ejemplo de Detección
```
Lectura: X=5.2, Y=0.3, Z=0.5
Promedio: X=4.8, Y=0.25, Z=0.4
Detección: X es dominante (4.8 > 3.5) ✓
Aislamiento: Y(0.25<0.8) ✓ Z(0.4<0.8) ✓
Resultado: Ejecutar acción Office → Abrir Excel
```

---

## 🔌 Endpoints de la API

### Health Check
```
GET /api/health
Respuesta: { status: "online", stats: {...} }
```

### Ejecutar Acción
```
POST /api/actions/execute
Body: { action: "office|web|media", url: "..." }
Respuesta: { status: "success", action: "..." }
```

### Obtener Estadísticas
```
GET /api/stats
Respuesta: { total_actions: 42, actions_by_type: {...} }
```

---

## 🎮 Uso de la Aplicación

### Interfaz Principal

#### 1. Estado de Conexión
- Indicador visual del estado del backend
- Última verificación de conexión
- Intentos de conexión realizados
- Botón para probar conexión manualmente

#### 2. Lectura Actual del Giroscopio
- Visualización en tiempo real de X, Y, Z
- Barras de progreso coloreadas:
  - 🔴 Rojo: Eje X (Office)
  - 🟢 Verde: Eje Y (Web)
  - 🔵 Azul: Eje Z (Media)
- Identificación de eje activo

#### 3. Estado de Monitoreo
- Indicador de monitoreo activo/pausado
- Color verde cuando está monitoreando
- Color gris cuando está pausado

#### 4. Última Acción Ejecutada
- Timestamp de la acción
- Nombre de la aplicación abierta
- Estado de ejecución (éxito/error)

#### 5. Controles
- **Iniciar**: Comienza monitoreo de giroscopio
- **Pausar**: Detiene monitoreo sin cerrar app
- **Limpiar**: Borra historial de lecturas

#### 6. Historial de Lecturas
- Últimas 20 lecturas capturadas
- Hora exacta (HH:MM:SS)
- Valores precisos en formato X.XXX

---

## 🔍 Detección de Problemas

### El giroscopio no funciona
- ✅ Verificar que la app se ejecuta en Android/iOS (no en Web)
- ✅ Permitir permisos de sensor en configuración del dispositivo
- ✅ Reiniciar la aplicación

### No se conecta al backend
- ✅ Verificar que backend está ejecutándose: `python run.py`
- ✅ Confirmar IP correcta en `gyroscope_controller.dart`
- ✅ Ambos dispositivos en misma red WiFi
- ✅ Desactivar firewall temporalmente para pruebas

### Las acciones no se ejecutan
- ✅ Verificar conexión backend (health check)
- ✅ Aumentar umbral si movimientos son muy suaves
- ✅ Revisar logs de terminal del backend
- ✅ Usar fallback local (automático si backend no responde)

### La detección es demasiado sensible
- ↓ Aumentar `movementThreshold` en gyroscope_controller.dart
- ↓ Aumentar `isolationThreshold` para ser más selectivo

---

## 📊 Estructura de Datos

### GyroscopeData
```dart
class GyroscopeData {
  final double x;                // Rotación eje X (rad/s)
  final double y;                // Rotación eje Y (rad/s)
  final double z;                // Rotación eje Z (rad/s)
  final DateTime timestamp;       // Momento de captura
}
```

### Respuesta Backend
```json
{
  "status": "success",
  "action": "office",
  "timestamp": "2025-12-17T14:30:45",
  "device_ip": "192.168.1.100"
}
```

---

## 🎓 Cómo Funciona la Detección

### Ejemplo Práctico: Abrir Office

```
1. Usuario gira teléfono hacia la izquierda (eje X dominante)
2. Sensor giroscopio captura: X=4.5, Y=0.2, Z=0.1 rad/s
3. Se repite 5 veces para confirmar
4. Promedio: X=4.5 > umbral(3.5) ✓
5. Aislamiento: Y(0.2<0.8) ✓, Z(0.1<0.8) ✓
6. ✓ DETECTADO: Movimiento Eje X
7. Ejecuta: _callBackend('office')
8. Backend abre Excel en Windows
9. UI muestra: "✓ Office abierto - 14:30:45"
10. Espera 2.5s (cooldown) antes de detectar otra acción
```

## 👨‍💻 Autor

Elkin Pabon - Desarrollado como proyecto de aplicación de sensores en Flutter.

