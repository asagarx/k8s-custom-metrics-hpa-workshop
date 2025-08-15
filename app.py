from flask import Flask, jsonify, Response, request
import time
from threading import Lock

app = Flask(__name__)

# Metrics storage
request_count = 0
request_lock = Lock()

@app.before_request
def track_requests():
    global request_count
    # Don't count requests to /metrics endpoint
    if request.path != '/metrics':
        with request_lock:
            request_count += 1

@app.route('/')
def home():
    return jsonify({"message": "Hello World!", "timestamp": time.time()})

@app.route('/health')
def health():
    return jsonify({"status": "healthy"})

@app.route('/api/data')
def get_data():
    return jsonify({"data": [1, 2, 3, 4, 5], "count": 5})

@app.route('/metrics')
def metrics():
    import os
    pod_name = os.environ.get('HOSTNAME', 'unknown')
    namespace = os.environ.get('POD_NAMESPACE', 'default')
    metrics_output = f"# HELP http_requests_total Total number of HTTP requests\n# TYPE http_requests_total counter\nhttp_requests_total{{pod=\"{pod_name}\",namespace=\"{namespace}\"}} {request_count}\n"
    return Response(metrics_output, mimetype='text/plain')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)