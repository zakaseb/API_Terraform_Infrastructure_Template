from flask import Flask, jsonify

app = Flask(__name__)

# Root endpoint
@app.route('/')
def home():
    return "Welcome to the Flask App!"

# Health check endpoint
@app.route('/health')
def health():
    return jsonify(status="healthy")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8887, debug=True)
