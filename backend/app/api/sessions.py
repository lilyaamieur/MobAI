from flask import Blueprint, request, jsonify
from collections import deque

# Queue for matchmaking
matchmaking_queue = deque()

# Create a Blueprint for session-related routes
bp = Blueprint('sessions', __name__)

# Create or join a session
@bp.route('/sessions/join', methods=['POST'])
def join_session():
    data = request.json
    user_id = data.get('user_id')

    if len(matchmaking_queue) > 0:
        # Pair with another player
        opponent_id = matchmaking_queue.popleft()
        session_data = {
            'session_type': 'online',
            'created_by': user_id
        }
        # Insert session into the database (replace with your database logic)
        session_id = 1  # Replace with actual session ID
        return jsonify({
            'session_id': session_id,
            'opponent_id': opponent_id,
            'status': 'matched'
        }), 201
    else:
        # Add player to the queue
        matchmaking_queue.append(user_id)
        return jsonify({
            'status': 'waiting',
            'message': 'Waiting for an opponent...'
        }), 200