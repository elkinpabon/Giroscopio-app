"""
Servicio para gestionar la conexión con el backend
"""
import requests
from datetime import datetime
import threading

class BackendConnection:
    """Gestiona la conexión con el backend Flask"""
    
    def __init__(self, backend_url):
        self.backend_url = backend_url
        self.is_connected = False
        self.last_ping = None
        self.device_ip = None
        self.error_message = ""
        
    def test_connection(self):
        """Probar conexión con el backend"""
        try:
            response = requests.get(
                f'{self.backend_url}/health',
                timeout=3
            )
            if response.status_code == 200:
                self.is_connected = True
                self.last_ping = datetime.now().isoformat()
                self.error_message = ""
                data = response.json()
                print(f"\n✅ CONECTADO AL BACKEND")
                print(f"   URL: {self.backend_url}")
                print(f"   Status: {data.get('status')}")
                print(f"   Timestamp: {self.last_ping}")
                return True
            else:
                self.is_connected = False
                self.error_message = f"Status code: {response.status_code}"
                print(f"\n❌ ERROR DE CONEXIÓN: {self.error_message}")
                return False
        except requests.exceptions.ConnectionError:
            self.is_connected = False
            self.error_message = "No se puede conectar. Verifica el backend."
            print(f"\n❌ ERROR: {self.error_message}")
            return False
        except requests.exceptions.Timeout:
            self.is_connected = False
            self.error_message = "Timeout: Backend no responde"
            print(f"\n❌ ERROR: {self.error_message}")
            return False
        except Exception as e:
            self.is_connected = False
            self.error_message = str(e)
            print(f"\n❌ ERROR: {self.error_message}")
            return False
    
    def get_stats(self):
        """Obtener estadísticas del backend"""
        try:
            response = requests.get(
                f'{self.backend_url}/stats',
                timeout=3
            )
            if response.status_code == 200:
                return response.json().get('stats', {})
            return {}
        except Exception as e:
            print(f"Error obteniendo estadísticas: {e}")
            return {}
    
    def get_status_dict(self):
        """Obtener diccionario con estado de conexión"""
        return {
            'is_connected': self.is_connected,
            'backend_url': self.backend_url,
            'last_ping': self.last_ping,
            'error_message': self.error_message,
            'timestamp': datetime.now().isoformat()
        }
