from flask import Flask, Response
from prometheus_client import Counter, Histogram, generate_latest
import time
import random

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests"
)

ERROR_COUNT = Counter(
    "http_errors_total",
    "Total HTTP errors"
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency"
)

@app.route("/")
def home():

    REQUEST_COUNT.inc()

    start = time.time()

    # simulate processing time
    time.sleep(random.uniform(0.1, 0.5))

    # simulate occasional error (5%)
    if random.random() < 0.05:
        ERROR_COUNT.inc()
        return "Internal Server Error", 500

    REQUEST_LATENCY.observe(time.time() - start)

    return "Flask monitoring app running"

@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype="text/plain")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
