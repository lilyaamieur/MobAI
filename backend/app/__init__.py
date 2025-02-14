from flask import Flask
from flask_socketio import SocketIO
from supabase import create_client, Client
import os
import dotenv

dotenv.load_dotenv()

# Initialize Flask app
app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins="*")

@app.route('/')
def index() :
    return 'Hello, World!'

# Initialize Supabase client
supabase: Client = create_client(
    os.getenv('SUPABASE_URL'),
    os.getenv('SUPABASE_ANON_KEY')
)

# Import API routes
from app.api import game, sessions
app.register_blueprint(game.bp)
app.register_blueprint(sessions.bp)

# WebSocket event for real-time updates
@socketio.on('join_session')
def handle_join_session(session_id, user_id):
    # Broadcast to all players in the session
    socketio.emit('session_update', {
        'session_id': session_id,
        'user_id': user_id,
        'message': 'A player has joined the session.'
    }, room=session_id)