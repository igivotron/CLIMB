from flask import Flask, request, jsonify, g
import sqlite3
import time
from ELO import update_rating # type: ignore

app = Flask(__name__)
USERS_DATABASE = './data/users.db'
WALL_DATABASE = './data/wall.db'
# Log file path
LOGS = './data/logs.txt'
score_colors = {"green":0, "yellow":100, "orange":300, "blue":400, "red":500, "black":600, "pink":700, "white":800}

def add_log(message):
    with open(LOGS, 'a') as log_file:
        log_file.write(message + '\n')

def get_db(database):
    if 'db' not in g:
        g.db = sqlite3.connect(database, check_same_thread=False)
        g.db.row_factory = sqlite3.Row
    return g.db

def get_db2(database):
    if 'gb2' not in g:
        g.gb2 = sqlite3.connect(database, check_same_thread=False)
        g.gb2.row_factory = sqlite3.Row
    return g.gb2

@app.teardown_appcontext
def close_db(error):
    db = g.pop('db', None)
    if db is not None:
        db.close()


def init_users_db():
    users_db = sqlite3.connect('./data/users.db', check_same_thread=False)
    users_cursor = users_db.cursor()
    users_cursor.execute('''
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        score INTEGER DEFAULT 300
        )
    ''')

    users_db.commit()
    users_db.close()

def init_wall_db():
    wall_db = sqlite3.connect('./data/wall.db', check_same_thread=False)
    wall_cursor = wall_db.cursor()
    wall_cursor.execute('''
    CREATE TABLE IF NOT EXISTS wall (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        color TEXT NOT NULL,
        location TEXT NOT NULL,
        score INTEGER DEFAULT 0
    )
    ''')
    wall_db.commit()
    wall_db.close()

@app.route("/")
def home():
    return "Welcome to the CLIMB API!"

## USER ##
@app.route("/user/add", methods=['POST'])
def add_user():
    users_db = get_db(USERS_DATABASE)
    cursor = users_db.cursor()
    username = request.json.get('username')
    if not username:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Error: Username is required")
        return jsonify({"error": "Username is required"}), 400
    
    try:
        cursor.execute("INSERT INTO users (username, score) VALUES (?, ?)", (username, 400))
        users_db.commit()
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - User added: {username}")
        return jsonify({"message": "User added successfully"}), 201
    except sqlite3.IntegrityError:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Error: Username already exists: {username}")
        return jsonify({"error": "Username already exists"}), 409


@app.route("/user/<string:name>", methods=['GET'])
def get_user(name):
    users_db = get_db(USERS_DATABASE)
    cursor = users_db.cursor()
    cursor.execute("SELECT * FROM users WHERE username = ?", (name,))
    user = cursor.fetchone()
    if user:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - User retrieved: {name}")
        return jsonify({"id": user[0], "username": user[1], "score": user[2]})

    else:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Error: User not found: {name}")
        return jsonify({"error": "User not found"}), 404

@app.route("/user/update/<string:name>/<int:wall_id>/<int:success>", methods=['PUT'])
def update_user(name, wall_id, success):
    print(f"Updating user {name} for wall {wall_id} with success value {success}")
    # 0 for failure, 1 for success
    users_db = get_db(USERS_DATABASE)
    wall_db = get_db2(WALL_DATABASE)
    user_cursor = users_db.cursor()
    wall_cursor = wall_db.cursor()

    user_cursor.execute("SELECT * FROM users WHERE username = ?", (name,))
    user = user_cursor.fetchone()
    wall_cursor.execute("SELECT * FROM wall WHERE id = ?", (wall_id,))
    wall = wall_cursor.fetchone()
    # wall = {"id": wall_id, "color": "blue", "location": "some_location", "score": 400}  # Mocked wall data for testing
    if not user:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - User Update Error: User not found: {name}")
        return jsonify({"error": "User not found"}), 404

    if not wall:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - User Update Error: Wall not found with ID {wall_id}")
        return jsonify({"error": "Wall not found"}), 404

    if success not in [0, 1]:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - User Update Error: Invalid success value: {success}")
        return jsonify({"error": "Invalid success value"}), 400

    new_user_score = update_rating(user["score"], wall["score"], success)
    user_cursor.execute("UPDATE users SET score = ? WHERE username = ?", (new_user_score, name))
    users_db.commit()

    sucess = 0 if success == 1 else 0
    new_wall_score = update_rating(wall["score"], new_user_score, success)
    wall_cursor.execute("UPDATE wall SET score = ? WHERE id = ?", (new_wall_score, wall_id))
    wall_db.commit()

    add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - User updated: {name}, new score: {new_user_score}")
    add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Wall updated: ID {wall_id}, new score: {new_wall_score}")
    
    return jsonify({"message": "User score updated successfully", "new_score": new_user_score}), 200


@app.route("/user/users", methods=['GET'])
def get_all_users():
    users_db = get_db(USERS_DATABASE)
    cursor = users_db.cursor()
    cursor.execute("SELECT * FROM users")
    users = cursor.fetchall()
    user_list = [{"id": user[0], "username": user[1], "score": user[2]} for user in users]
    return jsonify(user_list)


## WALL ##
@app.route("/wall/add", methods=['POST'])
def add_wall():
    wall_db = get_db(WALL_DATABASE)
    cursor = wall_db.cursor()

    data = request.get_json()
    color, location = data.get('color'), data.get('location')
    if not color or not location:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Error: Color and location are required")
        return jsonify({"error": "Color and location are required"}), 400
    
    score = score_colors.get(color, 0)
    try:
        cursor.execute("INSERT INTO wall (color, location, score) VALUES (?, ?, ?)", (color, location, score))
        wall_db.commit()
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Wall added: {color} at {location}")
        return jsonify({"message": "Wall added successfully"}), 201
    except sqlite3.IntegrityError:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Error: Wall already exists at {location}")
        return jsonify({"error": "Wall already exists at this location"}), 409
    
@app.route("/wall/<int:wall_id>", methods=['GET'])
def get_wall(wall_id):
    wall_db = get_db(WALL_DATABASE)
    cursor = wall_db.cursor()
    cursor.execute("SELECT * FROM wall WHERE id = ?", (wall_id,))
    wall = cursor.fetchone()
    if wall:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Wall retrieved: ID {wall_id}")
        return jsonify({"id": wall[0], "color": wall[1], "location": wall[2], "score": wall[3]})
    else:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Error: Wall not found with ID {wall_id}")
        return jsonify({"error": "Wall not found"}), 404

@app.route("/wall/walls", methods=['GET'])
def get_all_walls():
    wall_db = get_db(WALL_DATABASE)
    cursor = wall_db.cursor()
    cursor.execute("SELECT * FROM wall")
    walls = cursor.fetchall()
    wall_list = [{"id": wall[0], "color": wall[1], "location": wall[2], "score": wall[3]} for wall in walls]
    return jsonify(wall_list)

@app.route("/wall/remove/<int:wall_id>", methods=['DELETE'])
def remove_wall(wall_id):
    wall_db = get_db(WALL_DATABASE)
    cursor = wall_db.cursor()
    cursor.execute("SELECT * FROM wall WHERE id = ?", (wall_id,))
    wall = cursor.fetchone()
    
    if not wall:
        add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Error: Wall not found with ID {wall_id}")
        return jsonify({"error": "Wall not found"}), 404
    
    cursor.execute("DELETE FROM wall WHERE id = ?", (wall_id,))
    wall_db.commit()
    add_log(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - Wall removed: ID {wall_id}")
    
    return jsonify({"message": "Wall removed successfully"}), 200

@app.route("/walls/count", methods=['GET'])
def get_wall_count():
    wall_db = get_db(WALL_DATABASE)
    cursor = wall_db.cursor()
    cursor.execute("SELECT COUNT(*) FROM wall")
    count = cursor.fetchone()[0]
    return jsonify({"total_walls": count}), 200



if __name__ == "__main__":
    init_users_db()
    init_wall_db()
    app.run(host='0.0.0.0', port=5000)