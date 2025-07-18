
from flask import Flask, request, jsonify
import os
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv

# Charger les variables d'environnement depuis un fichier .env si présent
load_dotenv()

app = Flask(__name__)

# Paramètres de connexion MySQL depuis les variables d'environnement
MYSQL_HOST = os.getenv('MYSQL_HOST', 'localhost')
MYSQL_USER = os.getenv('MYSQL_USER', 'root')
MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '')
MYSQL_DB = os.getenv('MYSQL_DB', 'aatdb')

def get_db_connection():
    try:
        conn = mysql.connector.connect(
            host=MYSQL_HOST,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DB
        )
        return conn
    except Error as e:
        print(f"Erreur de connexion à MySQL: {e}")
        return None

@app.route('/')
def hello():
    return 'Hello from Flask on Azure VM!'

@app.route('/test-mysql')
def test_mysql():
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute('SELECT DATABASE();')
            db = cursor.fetchone()
            return jsonify({"status": "ok", "database": db[0]})
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)})
        finally:
            conn.close()
    else:
        return jsonify({"status": "error", "message": "Connexion MySQL impossible"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
