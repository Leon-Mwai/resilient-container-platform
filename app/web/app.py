from flask import Flask, jsonify
import os
import redis

app = Flask(__name__)

redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'localhost'),
    port=6379,
    decode_responses=True
)

@app.route('/')
def home():
    visits = redis_client.incr('visits')
    return jsonify({
        'message': 'Resilient E-commerce Platform',
        'visits': visits
    })

@app.route('/health')
def health():
    return 'OK', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)