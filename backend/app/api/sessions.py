from flask import Blueprint, request, jsonify
from app import supabase
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
        response = supabase.table('sessions').insert(session_data).execute()
        session_id = response.data[0]['id']

        # Add both players to the session
        supabase.table('session_participants').insert([
            {'session_id': session_id, 'user_id': user_id},
            {'session_id': session_id, 'user_id': opponent_id}
        ]).execute()

        return jsonify({
            'session_id': session_id,
            'opponent_id': opponent_id
        }), 201
    else:
        # Add player to the queue
        matchmaking_queue.append(user_id)
        return jsonify({'message': 'Waiting for an opponent...'}), 200