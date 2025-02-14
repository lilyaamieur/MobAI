from typing import Dict, Any
from flask import abort

def validate_session_input(data: Dict[str, Any]) -> bool:
    required_fields = ['session_type', 'user_id']
    
    if not all(field in data for field in required_fields):
        abort(400, description="Missing required fields")
    
    if data['session_type'] not in ['offline', 'online', 'multiplayer']:
        abort(400, description="Invalid session type")
    
    return True

def validate_drawing_input(data: Dict[str, Any]) -> bool:
    required_fields = ['session_id', 'user_id', 'drawing', 'prompt_id']
    
    if not all(field in data for field in required_fields):
        abort(400, description="Missing required fields")
    
    return True