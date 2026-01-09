import os
import time
import psycopg2
from flask import Flask

app = Flask(__name__)


@app.before_request
def log_request_info():
    app.logger.info(f"User-Agent: {request.headers.get('User-Agent')}")

def get_db_connection():
    # Данные для подключения берем из переменных окружения (их даст Оператор)
    conn = psycopg2.connect(
        host=os.environ['DB_HOST'],
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD']
    )
    return conn

# Функция ожидания базы (Retry Logic)
def init_db():
    retries = 5
    while retries > 0:
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('CREATE TABLE IF NOT EXISTS visits (id serial PRIMARY KEY, num integer);')
            # Если таблица пустая, вставим начальное значение
            cur.execute('INSERT INTO visits (num) SELECT 0 WHERE NOT EXISTS (SELECT * FROM visits);')
            conn.commit()
            cur.close()
            conn.close()
            print("Database initialized successfully!")
            return
        except Exception as e:
            print(f"DB not ready yet, retrying... Error: {e}")
            retries -= 1
            time.sleep(5)

# Инициализируем при старте
init_db()

@app.route('/')
def hello():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        # Увеличиваем счетчик атомарно
        cur.execute('UPDATE visits SET num = num + 1 RETURNING num;')
        count = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return f"Hello from Postgres (CNPG)! Visit count: {count}\n"
    except Exception as e:
        return f"Error connecting to DB: {str(e)}\n"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

