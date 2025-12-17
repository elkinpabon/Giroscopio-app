"""
Inicializador de la aplicación Flask
"""
from flask import Flask
from flask_cors import CORS
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def create_app():
    """Crear y configurar la aplicación Flask"""
    app = Flask(__name__)
    
    # Cargar configuración
    from app.config.settings import config
    app.config.from_object(config)
    
    # Habilitar CORS
    CORS(app, resources={r"/api/*": {"origins": "*"}})
    
    # Registrar blueprints
    from app.routes.api import api
    app.register_blueprint(api)
    
    # Logging
    logger.info('✓ Aplicación Flask inicializada')
    logger.info(f'✓ Debug mode: {app.config["DEBUG"]}')
    
    return app
