#!/usr/bin/env python3
from contextlib import contextmanager
from datetime import date, datetime, timedelta
from decimal import Decimal
from functools import wraps
from hashlib import pbkdf2_hmac
from hmac import compare_digest

import mariadb
import os
import secrets
import sys

from dotenv import load_dotenv
from flask import Flask, g, jsonify, request
from flask_cors import CORS

load_dotenv()

app = Flask(__name__)

_cors = os.getenv('CORS_ORIGINS', '').strip()
if _cors:
    CORS(app, resources={'/*': {'origins': [o.strip() for o in _cors.split(',') if o.strip()]}})
else:
    CORS(app)

PBKDF2_ROUNDS = 200_000
SESSION_TTL_HOURS = 8
HASH_PREFIX = 'pbkdf2_sha256'

@contextmanager
def db():
    conn = None
    try:
        conn = mariadb.connect(
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            host=os.getenv('DB_HOST', 'localhost'),
            port=int(os.getenv('DB_PORT', '3306')),
            database=os.getenv('DB_NAME'),
        )
        yield conn
        conn.commit()
    except Exception:
        if conn is not None:
            try:
                conn.rollback()
            except Exception:
                pass
        raise
    finally:
        if conn is not None:
            try:
                conn.close()
            except Exception:
                pass


def fetch_all(cur):
    columns = [d[0] for d in cur.description]
    return [dict(zip(columns, row)) for row in cur.fetchall()]


def jsonable(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, datetime):
        return value.isoformat(sep=' ')
    if isinstance(value, date):
        return value.isoformat()
    if isinstance(value, (bytes, bytearray)):
        return value.decode('utf-8', 'replace')
    return value


def dump(rows):
    return [{k: jsonable(v) for k, v in row.items()} for row in rows]

def hash_password(password):
    salt = secrets.token_hex(16)
    digest = pbkdf2_hmac('sha256', password.encode('utf-8'), bytes.fromhex(salt), PBKDF2_ROUNDS)
    return f'{HASH_PREFIX}${PBKDF2_ROUNDS}${salt}${digest.hex()}'


def verify_password(stored, password):
    if not stored.startswith(f'{HASH_PREFIX}$'):
        return compare_digest(stored, password), True

    try:
        _, rounds, salt, expected = stored.split('$')
        actual = pbkdf2_hmac('sha256', password.encode('utf-8'), bytes.fromhex(salt), int(rounds))
    except (ValueError, TypeError):
        return False, False

    return compare_digest(expected, actual.hex()), False

@contextmanager
def new_session(account_type, roll=None, tid=None):
    session_id = secrets.token_hex(32)  # 64 hex chars, matches CHAR(64)
    expires_at = datetime.now() + timedelta(hours=SESSION_TTL_HOURS)
    with db() as conn:
        cur = conn.cursor()
        cur.execute(
            'INSERT INTO SESSIONS (SESSION_ID, ACCOUNT_TYPE, ROLL, TID, EXPIRES_AT) VALUES (?, ?, ?, ?, ?)',
            (session_id, account_type, roll, tid, expires_at),
        )
        cur.close()
    yield session_id


def require_session(account_type):

    def decorator(view):
        @wraps(view)
        def wrapper(*args, **kwargs):
            session_id = ((request.get_json(silent=True) or {}).get('session_id')
                          or request.headers.get('X-Session-Id')
                          or '')
            session_id = session_id.strip()
            if not session_id:
                return jsonify({'message': 'no session'}), 401

            try:
                with db() as conn:
                    cur = conn.cursor()
                    cur.execute(
                        'SELECT ROLL, TID FROM SESSIONS '
                        'WHERE SESSION_ID = ? AND ACCOUNT_TYPE = ? AND EXPIRES_AT > NOW()',
                        (session_id, account_type),
                    )
                    row = cur.fetchone()
                    cur.close()
            except mariadb.Error as e:
                return jsonify({'message': f'Database error: {e}'}), 500

            if row is None:
                return jsonify({'message': 'session expired, log in again'}), 401

            g.owner = row[0] if account_type == 'student' else row[1]
            return view(*args, **kwargs)

        return wrapper

    return decorator


def read_json():
    return request.get_json(silent=True) or {}


@app.route('/login', methods=['POST'])  # student login
def login():
    data = read_json()
    roll = (data.get('roll') or '').strip()
    password = data.get('password') or ''

    if not roll or not password:
        return jsonify({'message': 'Roll number and password are required'}), 400

    try:
        with db() as conn:
            cur = conn.cursor()
            # NAME lives on STUDENT, the password lives on STUDENT_LOGIN
            cur.execute(
                'SELECT l.PASSWORD, p.NAME FROM STUDENT_LOGIN l '
                'JOIN STUDENT p ON p.ROLL = l.ROLL '
                'WHERE l.ROLL = ? AND p.is_active = 1',
                (roll,),
            )
            student = cur.fetchone()
            if student is None:
                cur.close()
                return jsonify({'message': 'roll number does not exist'}), 401

            stored, name = student[0], student[1]
            ok, is_plain = verify_password(stored, password)

            if is_plain and ok:
                cur.execute('UPDATE STUDENT_LOGIN SET PASSWORD = ? WHERE ROLL = ?',
                            (hash_password(password), roll))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    if not ok:
        return jsonify({'message': 'wrong password'}), 401

    with new_session('student', roll=roll) as session_id:
        return jsonify({
            'message': 'Login successful',
            'roll': roll,
            'name': name,
            'session_id': session_id,
        }), 200


@app.route('/teacher-login', methods=['POST'])  # teacher login
def teacher_login():
    data = read_json()
    tid = (data.get('tid') or data.get('roll') or '').strip()
    password = data.get('password') or ''

    if not tid or not password:
        return jsonify({'message': 'Teacher ID and password are required'}), 400

    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'SELECT l.PASSWORD, p.NAME FROM TEACHER_LOGIN l '
                'JOIN TEACHER p ON p.TID = l.TID '
                'WHERE l.TID = ? AND p.is_active = 1',
                (tid,),
            )
            teacher = cur.fetchone()
            if teacher is None:
                cur.close()
                return jsonify({'message': 'teacherid does not exist'}), 401

            stored, name = teacher[0], teacher[1]
            ok, is_plain = verify_password(stored, password)

            if is_plain and ok:
                cur.execute('UPDATE TEACHER_LOGIN SET PASSWORD = ? WHERE TID = ?',
                            (hash_password(password), tid))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    if not ok:
        return jsonify({'message': 'wrong password'}), 401

    with new_session('teacher', tid=tid) as session_id:
        return jsonify({
            'message': 'Login successful',
            'tid': tid,
            'name': name,
            'session_id': session_id,
        }), 200


@app.route('/logout', methods=['POST'])
def logout():
    session_id = (read_json().get('session_id') or '').strip()
    if session_id:
        try:
            with db() as conn:
                cur = conn.cursor()
                cur.execute('DELETE FROM SESSIONS WHERE SESSION_ID = ?', (session_id,))
                cur.close()
        except mariadb.Error:
            # logging out locally is enough even if the row lingers
            pass
    return jsonify({'message': 'Logged out'}), 200


@app.route('/api/student/dashboard', methods=['POST'])
@require_session('student')
def student_dashboard():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute('SELECT * FROM v_student_dashboard WHERE ROLL = ?', (g.owner,))
            row = cur.fetchone()
            if row is None:
                cur.close()
                return jsonify({'message': 'student not found or inactive'}), 404

            columns = [d[0] for d in cur.description]
            stats = dict(zip(columns, row))

            cur.execute(
                'SELECT ROUND(AVG(pct), 2) FROM ('
                '  SELECT SUM(m.SEM_MARKS) / SUM(a.MAX_MARKS) * 100 AS pct'
                '  FROM ACADEMICS m JOIN ASSESSMENTS a ON a.ASSESSMENT_ID = m.ASSESSMENT_ID'
                '  WHERE m.`S.ROLL` = ? GROUP BY a.COURSE_ID) per_course',
                (g.owner,),
            )
            stats['avg_percentage'] = cur.fetchone()[0]
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify({k: jsonable(v) for k, v in stats.items()}), 200


@app.route('/api/student/materials', methods=['POST'])
@require_session('student')
def student_materials():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'SELECT c.COURSE_NAME, m.TITLE, m.FILE_TYPE, m.FILE_SIZE, m.UPLOAD_DATE '
                'FROM STUDY_MATERIALS m '
                'JOIN COURSES c ON c.COURSE_ID = m.COURSE_ID '
                'JOIN STU_COURSES sc ON sc.C_ID = m.COURSE_ID '
                "WHERE sc.`S.ROLL` = ? AND sc.status = 'enrolled' "
                'ORDER BY m.UPLOAD_DATE DESC',
                (g.owner,),
            )
            rows = dump(fetch_all(cur))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify(rows), 200


@app.route('/api/student/academics', methods=['POST'])
@require_session('student')
def student_academics():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'SELECT c.COURSE_NAME, a.TITLE, a.MAX_MARKS, m.SEM_MARKS, '
                '       ROUND(m.SEM_MARKS / a.MAX_MARKS * 100, 2) AS percentage '
                'FROM ACADEMICS m '
                'JOIN ASSESSMENTS a ON a.ASSESSMENT_ID = m.ASSESSMENT_ID '
                'JOIN COURSES c ON c.COURSE_ID = a.COURSE_ID '
                "WHERE m.`S.ROLL` = ? AND m.SEM_MARKS <= a.MAX_MARKS "
                'ORDER BY c.COURSE_NAME, a.ASSESSMENT_DATE',
                (g.owner,),
            )
            rows = dump(fetch_all(cur))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify(rows), 200


@app.route('/api/student/attendance', methods=['POST'])
@require_session('student')
def student_attendance():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                "SELECT a.COURSE_ID, c.COURSE_NAME, COUNT(*) AS classes_held, "
                "       CAST(SUM(a.ATTENDENCE_STATUS = 'present') AS SIGNED) AS present_days, "
                "       CAST(SUM(a.ATTENDENCE_STATUS = 'late') AS SIGNED) AS late_days, "
                "       CAST(SUM(a.ATTENDENCE_STATUS = 'absent') AS SIGNED) AS absent_days, "
                "       CAST(SUM(a.ATTENDENCE_STATUS IN ('present','late')) AS SIGNED) AS attended, "
                '       ROUND(100.0 * SUM(a.ATTENDENCE_STATUS IN (\'present\',\'late\')) '
                '              / COUNT(*), 2) AS percentage '
                'FROM ATTENDENCE a JOIN COURSES c ON c.COURSE_ID = a.COURSE_ID '
                'WHERE a.`S.ROLL` = ? GROUP BY a.COURSE_ID, c.COURSE_NAME '
                'ORDER BY c.COURSE_NAME',
                (g.owner,),
            )
            rows = dump(fetch_all(cur))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify(rows), 200


@app.route('/api/student/notices', methods=['POST'])
@require_session('student')
def student_notices():
    limit = max(1, min(request.args.get('limit', default=50, type=int), 50))
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'SELECT n.NOTICE_ID, n.TITLE, n.CONTENT, n.PRIORITY, n.CREATED_AT, '
                '       t.NAME AS posted_by '
                'FROM NOTICES n LEFT JOIN TEACHER t ON t.TID = n.posted_by '
                'WHERE (n.EXPIRES_AT IS NULL OR n.EXPIRES_AT > NOW()) '
                "  AND n.AUDIENCE IN ('all','students') "
                'ORDER BY n.IS_PINNED DESC, n.CREATED_AT DESC LIMIT %s',
                (limit,),
            )
            rows = dump(fetch_all(cur))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify(rows), 200

@app.route('/api/teacher/dashboard', methods=['POST'])
@require_session('teacher')
def teacher_dashboard():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute('SELECT * FROM v_teacher_dashboard WHERE TID = ?', (g.owner,))
            row = cur.fetchone()
            if row is None:
                cur.close()
                return jsonify({'message': 'teacher not found or inactive'}), 404
            columns = [d[0] for d in cur.description]
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify({k: jsonable(v) for k, v in zip(columns, row)}), 200


@app.route('/api/teacher/courses', methods=['POST'])
@require_session('teacher')
def teacher_courses():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'SELECT c.COURSE_ID, c.COURSE_NAME, c.CREDITS, '
                '       COUNT(sc.`S.ROLL`) AS enrolled '
                'FROM COURSES c '
                'LEFT JOIN STU_COURSES sc ON sc.C_ID = c.COURSE_ID AND sc.status = \'enrolled\' '
                'WHERE c.TID = ? GROUP BY c.COURSE_ID, c.COURSE_NAME, c.CREDITS '
                'ORDER BY c.COURSE_NAME',
                (g.owner,),
            )
            rows = dump(fetch_all(cur))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify(rows), 200


@app.route('/api/teacher/academics', methods=['POST'])
@require_session('teacher')
def teacher_academics():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'SELECT c.COURSE_NAME, s.ROLL, s.NAME, a.TITLE, a.MAX_MARKS, '
                '       m.SEM_MARKS, ROUND(m.SEM_MARKS / a.MAX_MARKS * 100, 2) AS percentage '
                'FROM ACADEMICS m '
                'JOIN ASSESSMENTS a ON a.ASSESSMENT_ID = m.ASSESSMENT_ID '
                'JOIN COURSES c ON c.COURSE_ID = a.COURSE_ID '
                'JOIN STUDENT s ON s.ROLL = m.`S.ROLL` '
                'WHERE c.TID = ? ORDER BY c.COURSE_NAME, s.ROLL, a.ASSESSMENT_DATE',
                (g.owner,),
            )
            rows = dump(fetch_all(cur))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify(rows), 200


@app.route('/api/teacher/attendance', methods=['POST'])
@require_session('teacher')
def teacher_attendance():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'SELECT c.COURSE_NAME, a.CLASS_DATE, COUNT(*) AS total_count, '
                "       SUM(a.ATTENDENCE_STATUS IN ('present','late')) AS present_count "
                'FROM ATTENDENCE a JOIN COURSES c ON c.COURSE_ID = a.COURSE_ID '
                'WHERE c.TID = ? GROUP BY c.COURSE_NAME, a.CLASS_DATE '
                'ORDER BY a.CLASS_DATE DESC, c.COURSE_NAME LIMIT 60',
                (g.owner,),
            )
            rows = dump(fetch_all(cur))
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify(rows), 200


@app.route('/api/teacher/notices', methods=['GET', 'POST'])
@require_session('teacher')
def teacher_notices():
    if request.method == 'GET':
        try:
            with db() as conn:
                cur = conn.cursor()
                cur.execute(
                    'SELECT n.NOTICE_ID, n.TITLE, n.CONTENT, n.PRIORITY, n.AUDIENCE, '
                    '       n.IS_PINNED, n.CREATED_AT '
                    'FROM NOTICES n WHERE n.posted_by = ? '
                    'ORDER BY n.CREATED_AT DESC LIMIT 50',
                    (g.owner,),
                )
                rows = dump(fetch_all(cur))
                cur.close()
        except mariadb.Error as e:
            return jsonify({'message': f'Database error: {e}'}), 500
        return jsonify(rows), 200

    data = read_json()
    title = (data.get('title') or '').strip()
    content = (data.get('content') or '').strip()
    priority = (data.get('priority') or 'normal').strip()
    audience = (data.get('audience') or 'all').strip()

    if not title or not content:
        return jsonify({'message': 'title and content are required'}), 400
    if len(title) > 200:
        return jsonify({'message': 'title is too long'}), 400
    if priority not in ('low', 'normal', 'high', 'urgent'):
        return jsonify({'message': 'invalid priority'}), 400
    if audience not in ('all', 'students', 'teachers'):
        return jsonify({'message': 'invalid audience'}), 400

    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute(
                'INSERT INTO NOTICES (TITLE, CONTENT, PRIORITY, AUDIENCE, posted_by) '
                'VALUES (?, ?, ?, ?, ?)',
                (title, content, priority, audience, g.owner),
            )
            notice_id = cur.lastrowid
            cur.close()
    except mariadb.Error as e:
        return jsonify({'message': f'Database error: {e}'}), 500

    return jsonify({'message': 'notice posted', 'notice_id': notice_id}), 201


@app.route('/health', methods=['GET'])  # server health teller
def health():
    try:
        with db() as conn:
            cur = conn.cursor()
            cur.execute('SELECT 1')
            cur.fetchone()
            cur.close()
    except mariadb.Error as e:
        return jsonify({'status': 'database unreachable', 'error': str(e)}), 503
    return jsonify({'status': 'Server is running'}), 200


if __name__ == '__main__':
    app.run(
        debug=os.getenv('FLASK_DEBUG', '1') == '1',
        host=os.getenv('HOST', '127.0.0.1'),
        port=int(os.getenv('PORT', '8080')),
    )
