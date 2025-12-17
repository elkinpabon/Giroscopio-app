import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

/// Servicio para ejecutar acciones según el movimiento del giroscopio
class ActionService {
  /// Abre Microsoft Office en Windows
  static Future<void> openOffice() async {
    try {
      if (Platform.isWindows) {
        // Intenta abrir Excel como Office por defecto
        await Process.run('start', ['excel'], runInShell: true);
      }
    } catch (e) {
      print('Error al abrir Office: $e');
    }
  }

  /// Abre una página web
  static Future<void> openWebpage(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        print('No se pudo abrir la URL: $url');
      }
    } catch (e) {
      print('Error al abrir página web: $e');
    }
  }

  /// Abre el reproductor de medios (Windows Media Player)
  static Future<void> openMediaPlayer() async {
    try {
      if (Platform.isWindows) {
        await Process.run('wmplayer', [], runInShell: true);
      }
    } catch (e) {
      print('Error al abrir Media Player: $e');
    }
  }

  /// Ejecuta un comando personalizado
  static Future<void> executeCommand(String command) async {
    try {
      await Process.run('cmd', ['/c', command], runInShell: true);
    } catch (e) {
      print('Error al ejecutar comando: $e');
    }
  }
}
