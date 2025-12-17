"""
Punto de entrada del backend
"""
import os
import sys
import logging

# Agregar el directorio actual al path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import create_app

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


if __name__ == '__main__':
    # Crear aplicación
    app = create_app()
    
    # Configuración del servidor
    PORT = 5000
    HOST = '0.0.0.0'
    
    logger.info(f'🚀 Iniciando backend en http://{HOST}:{PORT}')
    logger.info('📱 Flutter app se conectará aquí')
    logger.info('⏸️  Presiona Ctrl+C para detener')
    
    # Ejecutar servidor
    app.run(
        host=HOST,
        port=PORT,
        debug=True,
        use_reloader=True,
        threaded=True
    )
