#!/usr/bin/env python3
from flask import Flask, request, jsonify
from flask_cors import CORS
import mariadb
import sys
import os
from dotenv import load_dotenv

# Load local environment variables
load_dotenv()

#CORS = Cross Origin Resource Sharing
app = Flask(__name__)
CORS(app)

# MariaDB Configuration from .env
try:
    conn = mariadb.connect(
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        host=os.getenv('DB_HOST', 'localhost'),
        port=int(os.getenv('DB_PORT', '3306')),
        database=os.getenv('DB_NAME')
    )
    print("[✓] Connected to MariaDB successfully")
except mariadb.Error as e:
    print(f"[✗] Error connecting to MariaDB: {e}")
    sys.exit(1)
except (TypeError, ValueError) as e:
    print(f"[✗] Invalid DB configuration: {e}")
    sys.exit(1)


@app.route('/login', methods=['POST']) # This is the student login maintainer
def login():
    cur = None
    try:
        data = request.get_json(silent=True) or {}
        roll = (data.get('roll') or '').strip()
        password = data.get('password') or ''

        if not roll or not password:
            return jsonify({'message': 'Roll number and password are required'}), 400

        # Query the database
        cur = conn.cursor()
        cur.execute(
            "SELECT ROLL, PASSWORD, NAME FROM StudentLogin WHERE ROLL = ?",
            (roll,)
        )
        student = cur.fetchone()

        if student is None:
            return jsonify({'message': 'roll number does not exist'}), 401

        # student[0] = ROLL, student[1] = PASSWORD, student[2] = NAME
        if student[1] == password:
            return jsonify({
                'message': 'Login successful',
                'roll': student[0],
                'name': student[2]
            }), 200
        else:
            return jsonify({'message': 'wrong password'}), 401

    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500
    except Exception as e:
        return jsonify({'message': f'Server error: {e}'}), 500
    finally:
        if cur is not None:
            try:
                cur.close()
            except Exception:
                pass


@app.route('/teacher-login', methods=['POST']) # This is the teacher's login maintainer
def teacher_login():
    cur = None
    try:
        data = request.get_json(silent=True) or {}
        tid = (data.get('tid') or data.get('roll') or '').strip()
        password = data.get('password') or ''

        if not tid or not password:
            return jsonify({'message': 'Teacher ID and password are required'}), 400

        cur = conn.cursor()
        cur.execute(
            "SELECT TID, PASSWORD, NAME FROM TeacherLogin WHERE TID = ?",
            (tid,)
        )
        teacher = cur.fetchone()

        if teacher is None:
            return jsonify({'message': 'teacherid does not exist'}), 401

        # teacher[0] = TID, teacher[1] = PASSWORD, teacher[2] = NAME
        if teacher[1] == password:
            return jsonify({
                'message': 'Login successful',
                'tid': teacher[0],
                'name': teacher[2]
            }), 200
        else:
            return jsonify({'message': 'wrong password'}), 401

    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500
    except Exception as e:
        return jsonify({'message': f'Server error: {e}'}), 500
    finally:
        if cur is not None:
            try:
                cur.close()
            except Exception:
                pass


@app.route('/health', methods=['GET']) # Server health teller
def health():
    return jsonify({'status': 'Server is running'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='localhost', port=8080)
