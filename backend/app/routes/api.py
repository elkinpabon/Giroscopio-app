"""
Rutas principales de la API con logs mejorados
"""
from flask import Blueprint, request, jsonify
from app.actions.executor import ActionExecutor
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

# Crear blueprint
api = Blueprint('api', __name__, url_prefix='/api')

# Estadísticas globales
stats = {
    'total_requests': 0,
    'total_actions': 0,
    'actions_by_type': {
        'office': 0,
        'web': 0,
        'media': 0
    },
    'connected_devices': []
}


def log_request(action, device_ip, status, details=''):
    """Registrar una petición con timestamp"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    status_icon = '✓' if status else '✗'
    print(f"\n[{timestamp}] {status_icon} {action.upper()}")
    print(f"   IP Dispositivo: {device_ip}")
    if details:
        print(f"   Detalles: {details}")
    logger.info(f"{status_icon} {action} | IP: {device_ip} | {details}")


@api.route('/health', methods=['GET'])
def health():
    """Verificar que el servidor está activo"""
    client_ip = request.remote_addr
    stats['total_requests'] += 1
    
    log_request('HEALTH_CHECK', client_ip, True, 'Servidor online')
    
    return jsonify({
        'status': 'online',
        'message': 'Backend de giroscopio activo',
        'timestamp': datetime.now().isoformat(),
        'stats': stats
    }), 200


@api.route('/actions/office', methods=['POST'])
def open_office():
    """Ejecutar: Abrir Office"""
    client_ip = request.remote_addr
    stats['total_requests'] += 1
    stats['total_actions'] += 1
    stats['actions_by_type']['office'] += 1
    
    if client_ip not in stats['connected_devices']:
        stats['connected_devices'].append(client_ip)
        print(f"\n🔌 NUEVO DISPOSITIVO CONECTADO: {client_ip}")
        logger.info(f"🔌 Dispositivo conectado: {client_ip}")
    
    result = ActionExecutor.open_office()
    log_request('OFFICE', client_ip, result['success'], f"Total acciones: {stats['total_actions']}")
    
    status_code = 200 if result['success'] else 500
    result['stats'] = stats
    return jsonify(result), status_code


@api.route('/actions/web', methods=['POST'])
def open_web():
    """Ejecutar: Abrir página web"""
    client_ip = request.remote_addr
    data = request.get_json() or {}
    url = data.get('url', 'https://www.google.com')
    
    stats['total_requests'] += 1
    stats['total_actions'] += 1
    stats['actions_by_type']['web'] += 1
    
    if client_ip not in stats['connected_devices']:
        stats['connected_devices'].append(client_ip)
        print(f"\n🔌 NUEVO DISPOSITIVO CONECTADO: {client_ip}")
        logger.info(f"🔌 Dispositivo conectado: {client_ip}")
    
    result = ActionExecutor.open_webpage(url)
    log_request('WEB', client_ip, result['success'], f"URL: {url} | Total acciones: {stats['total_actions']}")
    
    status_code = 200 if result['success'] else 500
    result['stats'] = stats
    return jsonify(result), status_code


@api.route('/actions/media', methods=['POST'])
def open_media():
    """Ejecutar: Abrir Media Player"""
    client_ip = request.remote_addr
    stats['total_requests'] += 1
    stats['total_actions'] += 1
    stats['actions_by_type']['media'] += 1
    
    if client_ip not in stats['connected_devices']:
        stats['connected_devices'].append(client_ip)
        print(f"\n🔌 NUEVO DISPOSITIVO CONECTADO: {client_ip}")
        logger.info(f"🔌 Dispositivo conectado: {client_ip}")
    
    result = ActionExecutor.open_media_player()
    log_request('MEDIA', client_ip, result['success'], f"Total acciones: {stats['total_actions']}")
    
    status_code = 200 if result['success'] else 500
    result['stats'] = stats
    return jsonify(result), status_code


@api.route('/actions/custom', methods=['POST'])
def open_custom():
    """Ejecutar: Abrir aplicación personalizada"""
    client_ip = request.remote_addr
    data = request.get_json() or {}
    app_path = data.get('app_path')
    
    if not app_path:
        log_request('CUSTOM', client_ip, False, 'app_path no especificado')
        return jsonify({
            'success': False,
            'message': 'app_path es requerido',
            'action': 'custom',
            'stats': stats
        }), 400
    
    stats['total_requests'] += 1
    result = ActionExecutor.open_app(app_path)
    log_request('CUSTOM', client_ip, result['success'], f"App: {app_path}")
    
    status_code = 200 if result['success'] else 500
    result['stats'] = stats
    return jsonify(result), status_code


@api.route('/actions/command', methods=['POST'])
def execute_command():
    """Ejecutar: Comando personalizado"""
    client_ip = request.remote_addr
    data = request.get_json() or {}
    command = data.get('command')
    
    if not command:
        log_request('COMMAND', client_ip, False, 'command no especificado')
        return jsonify({
            'success': False,
            'message': 'command es requerido',
            'action': 'command',
            'stats': stats
        }), 400
    
    stats['total_requests'] += 1
    result = ActionExecutor.execute_command(command)
    log_request('COMMAND', client_ip, result['success'], f"Cmd: {command[:50]}")
    
    status_code = 200 if result['success'] else 500
    result['stats'] = stats
    return jsonify(result), status_code


@api.route('/actions/execute', methods=['POST'])
def execute_action():
    """
    Ejecutar acción genérica
    
    Body esperado:
    {
        "action": "office|web|media",
        "url": "https://..." (solo para web)
    }
    """
    client_ip = request.remote_addr
    data = request.get_json() or {}
    action = data.get('action')
    
    stats['total_requests'] += 1
    
    if not action:
        log_request('EXECUTE', client_ip, False, 'action no especificado')
        return jsonify({
            'success': False,
            'message': 'action es requerido',
            'stats': stats
        }), 400
    
    if client_ip not in stats['connected_devices']:
        stats['connected_devices'].append(client_ip)
        print(f"\n🔌 NUEVO DISPOSITIVO CONECTADO: {client_ip}")
        logger.info(f"🔌 Dispositivo conectado: {client_ip}")
    
    if action == 'office':
        stats['total_actions'] += 1
        stats['actions_by_type']['office'] += 1
        result = ActionExecutor.open_office()
        log_request('EXECUTE->OFFICE', client_ip, result['success'], f"Total acciones: {stats['total_actions']}")
    elif action == 'web':
        stats['total_actions'] += 1
        stats['actions_by_type']['web'] += 1
        url = data.get('url', 'https://www.google.com')
        result = ActionExecutor.open_webpage(url)
        log_request('EXECUTE->WEB', client_ip, result['success'], f"URL: {url} | Total acciones: {stats['total_actions']}")
    elif action == 'media':
        stats['total_actions'] += 1
        stats['actions_by_type']['media'] += 1
        result = ActionExecutor.open_media_player()
        log_request('EXECUTE->MEDIA', client_ip, result['success'], f"Total acciones: {stats['total_actions']}")
    else:
        log_request('EXECUTE', client_ip, False, f'Acción no válida: {action}')
        return jsonify({
            'success': False,
            'message': f'Acción no válida: {action}',
            'valid_actions': ['office', 'web', 'media'],
            'stats': stats
        }), 400
    
    status_code = 200 if result['success'] else 500
    result['stats'] = stats
    return jsonify(result), status_code


@api.route('/stats', methods=['GET'])
def get_stats():
    """Obtener estadísticas del servidor"""
    client_ip = request.remote_addr
    print(f"\n📊 SOLICITUD DE ESTADÍSTICAS desde {client_ip}")
    logger.info(f"📊 Estadísticas solicitadas desde {client_ip}")
    
    return jsonify({
        'status': 'ok',
        'timestamp': datetime.now().isoformat(),
        'stats': stats,
        'message': 'Estadísticas del servidor'
    }), 200


@api.errorhandler(404)
def not_found(error):
    """Manejar error 404"""
    return jsonify({
        'success': False,
        'message': 'Endpoint no encontrado',
        'error': str(error)
    }), 404


@api.errorhandler(500)
def server_error(error):
    """Manejar error 500"""
    return jsonify({
        'success': False,
        'message': 'Error interno del servidor',
        'error': str(error)
    }), 500
