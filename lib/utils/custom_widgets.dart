import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar información de sensores
class SensorInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? backgroundColor;

  const SensorInfoCard({
    super.key,
    required this.title,
    required this.children,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar estado de conexión con el backend
class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final String status;
  final String lastCheck;
  final int attempts;
  final VoidCallback onTestConnection;

  const ConnectionStatusWidget({
    super.key,
    required this.isConnected,
    required this.status,
    required this.lastCheck,
    required this.attempts,
    required this.onTestConnection,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isConnected
        ? Colors.green.withAlpha(25)
        : Colors.red.withAlpha(25);
    final borderColor = isConnected ? Colors.green : Colors.red;
    final statusText = isConnected ? 'CONECTADO' : 'DESCONECTADO';
    final icon = isConnected ? Icons.check_circle_outline : Icons.error_outline;

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: borderColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: borderColor,
                            ),
                      ),
                      Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Última verificación:',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        lastCheck,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intentos:',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '$attempts',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTestConnection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: borderColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Probar Conexión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar un valor de sensor con barra de progreso
class SensorValueDisplay extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final double threshold;

  const SensorValueDisplay({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.threshold,
  });

  @override
  Widget build(BuildContext context) {
    final absValue = value.abs();
    final isActive = absValue > threshold;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.sensors, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (absValue / 10).clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isActive ? color : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toStringAsFixed(2),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isActive ? color : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar estado de acción
class ActionStatusWidget extends StatelessWidget {
  final String actionText;
  final bool isSuccess;

  const ActionStatusWidget({
    super.key,
    required this.actionText,
    required this.isSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSuccess ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.cancel,
              color: isSuccess ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                actionText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
