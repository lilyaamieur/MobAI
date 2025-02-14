from flask import Blueprint, request, jsonify

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

    # Insert guess into the database (replace with your database logic)
    return jsonify({
        'ai_guess': ai_guess,
        'score': score
    }), 201