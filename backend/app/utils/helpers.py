from typing import Dict, Any
from datetime import datetime

def format_session_data(session_data: Dict[str, Any]) -> Dict[str, Any]:
    return {
        'id': session_data['id'],
        'type': session_data['session_type'],
        'start_time': datetime.fromisoformat(session_data['start_time']),
        'participants': session_data.get('session_participants', [])
    }

def calculate_score(guess_data: Dict[str, Any]) -> int:
    base_score = 100
    confidence = guess_data.get('confidence', 0)
    time_taken = guess_data.get('time_taken', 30)
    
    score = base_score * confidence
    time_penalty = max(0, (time_taken - 10) / 2)
    return max(0, int(score - time_penalty))