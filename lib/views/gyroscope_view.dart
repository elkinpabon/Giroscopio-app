import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gyroscope_controller.dart';
import '../utils/custom_widgets.dart';

class GyroscopeView extends StatelessWidget {
  final GyroscopeController controller = Get.put(GyroscopeController());

  GyroscopeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control por Giroscopio'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Widget de estado de conexión
              Obx(() {
                return ConnectionStatusWidget(
                  isConnected: controller.isConnected.value,
                  status: controller.connectionStatus.value,
                  lastCheck: controller.lastConnectionCheck.value,
                  attempts: controller.connectionAttempts.value,
                  onTestConnection: controller.testConnection,
                );
              }),

              const SizedBox(height: 24),

              // Título de la lectura actual
              const SizedBox(height: 16),
              Text(
                'Lectura Actual del Giroscopio',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Card con las lecturas del giroscopio
              Obx(() {
                final data = controller.currentReading.value;
                if (data == null) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text('Esperando datos del giroscopio...'),
                        ],
                      ),
                    ),
                  );
                }

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSensorRow(
                          'Eje X (Oficina)',
                          data.x,
                          Colors.red,
                          context,
                        ),
                        const SizedBox(height: 12),
                        _buildSensorRow(
                          'Eje Y (Navegador)',
                          data.y,
                          Colors.green,
                          context,
                        ),
                        const SizedBox(height: 12),
                        _buildSensorRow(
                          'Eje Z (Media)',
                          data.z,
                          Colors.blue,
                          context,
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Eje Activo: ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              controller.getActiveAxis(),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Estado de monitoreo
              Obx(() {
                return Card(
                  color: controller.isMonitoring.value
                      ? Colors.green[100]
                      : Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          controller.isMonitoring.value
                              ? Icons.check_circle
                              : Icons.pause_circle,
                          color: controller.isMonitoring.value
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          controller.isMonitoring.value
                              ? 'Monitoreando...'
                              : 'Monitoreo pausado',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Última acción ejecutada
              Obx(() {
                if (controller.lastAction.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Card(
                  color: Colors.amber[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Última Acción:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.lastAction.value,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Botones de control - Responsive
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.startMonitoring(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.stopMonitoring(),
                    icon: const Icon(Icons.pause),
                    label: const Text('Pausar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => controller.clearHistory(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Limpiar'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Historial de lecturas
              Text(
                'Historial de Lecturas',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Obx(() {
                if (controller.gyroscopeHistory.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Sin historial',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }

                return Card(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.gyroscopeHistory.length,
                    itemBuilder: (context, index) {
                      final data = controller.gyroscopeHistory[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${data.timestamp.hour}:${data.timestamp.minute}:${data.timestamp.second}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              'X:${data.x.toStringAsFixed(3)} | Y:${data.y.toStringAsFixed(3)} | Z:${data.z.toStringAsFixed(3)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(
    String label,
    double value,
    Color color,
    BuildContext context,
  ) {
    final absValue = value.abs();
    final isActive = absValue > GyroscopeController.movementThreshold;

    return Row(
      children: [
        Icon(Icons.sensors, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (absValue / 10).clamp(0, 1),
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isActive ? color : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isActive ? color : Colors.grey,
          ),
        ),
      ],
    );
  }
}
