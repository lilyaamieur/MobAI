from flask import Blueprint, request, jsonify
from app import supabase, socketio

# Create a Blueprint for game-related routes
bp = Blueprint('game', __name__)

# Submit a drawing
@bp.route('/game/submit_drawing', methods=['POST'])
def submit_drawing():
    data = request.json
    session_id = data.get('session_id')
    user_id = data.get('user_id')
    drawing_data = data.get('drawing_data')  # Base64 or other format

    # Simulate AI guess
    ai_guess = 'Computer'  # Dummy AI guess
    score = 100 if ai_guess == 'Computer' else 0

    # Insert guess into Supabase
    supabase.table('guesses').insert({
        'session_id': session_id,
        'user_id': user_id,
        'guess_text': ai_guess,
        'is_correct': True,
        'confidence': 1.0  # Dummy confidence score
    }).execute()

    # Broadcast the AI guess to both players
    socketio.emit('drawing_submitted', {
        'session_id': session_id,
        'user_id': user_id,
        'ai_guess': ai_guess,
        'score': score
    }, room=session_id)

    return jsonify({
        'ai_guess': ai_guess,
        'score': score
    }), 201