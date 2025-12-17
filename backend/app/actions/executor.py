"""
Servicio para ejecutar acciones en Windows
"""
import subprocess
import webbrowser
import os
import logging
import platform
from pathlib import Path

logger = logging.getLogger(__name__)


class ActionExecutor:
    """Ejecuta acciones en la PC"""

    @staticmethod
    def open_office():
        """Abre Microsoft Word"""
        try:
            # Rutas comunes de Word en Windows
            word_paths = [
                r"C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE",
                r"C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE",
                r"C:\Program Files\Microsoft Office\Office16\WINWORD.EXE",
                r"C:\Program Files\Microsoft Office 365\root\Office16\WINWORD.EXE",
                r"C:\Program Files (x86)\Microsoft Office\Office365\WINWORD.EXE",
            ]
            
            # Intentar con rutas específicas
            for path in word_paths:
                if os.path.exists(path):
                    subprocess.Popen([path])
                    logger.info(f'✓ Word abierto desde: {path}')
                    return {
                        'success': True,
                        'message': 'Microsoft Word abierto correctamente',
                        'action': 'office'
                    }
            
            # Fallback: usar comando del sistema
            subprocess.Popen('start winword', shell=True)
            logger.info('✓ Word abierto (comando sistema)')
            return {
                'success': True,
                'message': 'Microsoft Word abierto correctamente',
                'action': 'office'
            }
        except Exception as e:
            logger.error(f'✗ Error abriendo Word: {e}')
            return {
                'success': False,
                'message': f'Error: {str(e)}',
                'action': 'office'
            }

    @staticmethod
    def open_webpage(url='https://www.google.com'):
        """Abre Chrome con una página web"""
        try:
            # Rutas comunes de Chrome en Windows
            chrome_paths = [
                r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                r"C:\Users\%USERNAME%\AppData\Local\Google\Chrome\Application\chrome.exe",
            ]
            
            # Expandir %USERNAME% si está presente
            chrome_paths = [path.replace('%USERNAME%', os.getenv('USERNAME', '')) for path in chrome_paths]
            
            # Intentar con rutas específicas
            for path in chrome_paths:
                if os.path.exists(path):
                    subprocess.Popen([path, url])
                    logger.info(f'✓ Chrome abierto: {url} desde {path}')
                    return {
                        'success': True,
                        'message': f'Chrome abierto: {url}',
                        'action': 'web',
                        'url': url
                    }
            
            # Fallback: usar comando del sistema
            subprocess.Popen(f'start chrome "{url}"', shell=True)
            logger.info(f'✓ Chrome abierto (comando sistema): {url}')
            return {
                'success': True,
                'message': f'Chrome abierto: {url}',
                'action': 'web',
                'url': url
            }
        except Exception as e:
            logger.error(f'✗ Error abriendo Chrome: {e}')
            return {
                'success': False,
                'message': f'Error: {str(e)}',
                'action': 'web'
            }

    @staticmethod
    def open_media_player():
        """Abre Windows Media Player"""
        try:
            # Rutas comunes de Media Player
            media_player_paths = [
                r"C:\Program Files\Windows Media Player\wmplayer.exe",
                r"C:\Program Files (x86)\Windows Media Player\wmplayer.exe",
            ]
            
            # Intentar con rutas específicas
            for path in media_player_paths:
                if os.path.exists(path):
                    subprocess.Popen([path])
                    logger.info(f'✓ Media Player abierto desde: {path}')
                    return {
                        'success': True,
                        'message': 'Windows Media Player abierto correctamente',
                        'action': 'media'
                    }
            
            # Fallback: usar comando del sistema
            subprocess.Popen('start wmplayer.exe', shell=True)
            logger.info('✓ Media Player abierto (comando sistema)')
            return {
                'success': True,
                'message': 'Windows Media Player abierto correctamente',
                'action': 'media'
            }
        except Exception as e:
            logger.error(f'✗ Error abriendo Media Player: {e}')
            return {
                'success': False,
                'message': f'Error: {str(e)}',
                'action': 'media'
            }

    @staticmethod
    def open_app(app_path):
        """Abre una aplicación personalizada"""
        try:
            if os.path.exists(app_path):
                subprocess.Popen([app_path])
                logger.info(f'✓ Aplicación abierta: {app_path}')
                return {
                    'success': True,
                    'message': f'Aplicación abierta: {app_path}',
                    'action': 'custom'
                }
            else:
                logger.error(f'✗ Archivo no encontrado: {app_path}')
                return {
                    'success': False,
                    'message': f'Archivo no encontrado: {app_path}',
                    'action': 'custom'
                }
        except Exception as e:
            logger.error(f'✗ Error abriendo aplicación: {e}')
            return {
                'success': False,
                'message': f'Error: {str(e)}',
                'action': 'custom'
            }

    @staticmethod
    def execute_command(command):
        """Ejecuta un comando del sistema"""
        try:
            subprocess.run(command, shell=True, check=True)
            logger.info(f'✓ Comando ejecutado: {command}')
            return {
                'success': True,
                'message': f'Comando ejecutado: {command}',
                'action': 'command'
            }
        except Exception as e:
            logger.error(f'✗ Error ejecutando comando: {e}')
