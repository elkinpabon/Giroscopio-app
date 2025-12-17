"""
Configuración de la aplicación Flask
"""

class Config:
    """Configuración base"""
    DEBUG = False
    TESTING = False
    SECRET_KEY = 'giroscopio-app-secret-key'
    JSON_SORT_KEYS = False


class DevelopmentConfig(Config):
    """Configuración para desarrollo"""
    DEBUG = True
    DEVELOPMENT = True


class ProductionConfig(Config):
    """Configuración para producción"""
    DEBUG = False
    DEVELOPMENT = False


# Configuración activa
config = DevelopmentConfig()
