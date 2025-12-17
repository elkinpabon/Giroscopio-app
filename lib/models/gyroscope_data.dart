/// Modelo que representa los datos del giroscopio
class GyroscopeData {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  GyroscopeData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  @override
  String toString() => 'GyroscopeData(x: $x, y: $y, z: $z)';
}
