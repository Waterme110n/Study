import re

from flask import Flask, jsonify, request

app = Flask(__name__)
users = {}
user_id_counter = 1

initial_users = [
    {"name": "John Doe", "email": "john@example.com"},
    {"name": "Jane Smith", "email": "jane@example.com"}
]

for user in initial_users:
    user['id'] = user_id_counter
    users[user_id_counter] = user
    user_id_counter += 1

def is_valid_email(email):
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    return re.match(pattern, email) is not None

def is_valid_username(username):
    return not any(char in username for char in ['_', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')'])


@app.route('/')
def home():
    return "Welcome to the User API! Use /api/v1/users for user operations."

@app.route('/api/v1/users', methods=['GET'])
def get_all_users():
    page = request.args.get('page', default=1, type=int)
    limit = request.args.get('limit', default=10, type=int)

    if page < 1 or limit < 1:
        return jsonify({'error': 'Page and limit must be positive integers'}), 400

    start = (page - 1) * limit
    end = start + limit
    users_list = list(users.values())[start:end]

    return jsonify(users_list), 200

@app.route('/api/v1/users', methods=['POST'])
def create_user():
    global user_id_counter
    user_data = request.json

    if not user_data:
        return jsonify({'error': 'Request body cannot be empty'}), 400

    if 'name' not in user_data or 'email' not in user_data:
        return jsonify({'error': 'Missing name or email'}), 400

    if not is_valid_email(user_data['email']):
        return jsonify({'error': 'Invalid email format'}), 400

    if not is_valid_username(user_data['name']):
        return jsonify({'error': 'Username contains invalid characters'}), 400

    user_data['id'] = user_id_counter
    users[user_id_counter] = user_data
    user_id_counter += 1
    return jsonify(user_data), 201

@app.route('/api/v1/users/<int:user_id>', methods=['GET'])
def read_user(user_id):
    user = users.get(user_id)
    if user:
        return jsonify(user), 200
    return jsonify({'error': 'User not found'}), 404

@app.route('/api/v1/users/<int:user_id>', methods=['PUT'])
def update_user(user_id):
    user = users.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    user_data = request.json

    if not user_data:
        return jsonify({'error': 'Request body cannot be empty'}), 400

    if 'email' in user_data and not is_valid_email(user_data['email']):
        return jsonify({'error': 'Invalid email format'}), 400

    if 'name' in user_data and not is_valid_username(user_data['name']):
        return jsonify({'error': 'Username contains invalid characters'}), 400

    try:
        user.update(user_data)
        return jsonify(user), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/v1/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    if user_id in users:
        del users[user_id]
        return jsonify({'message': 'User deleted'}), 204
    return jsonify({'error': 'User not found'}), 404

if __name__ == '__main__':
    print("Сервер запущен на http://localhost:5000")
    app.run(debug=True)