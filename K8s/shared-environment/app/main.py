from flask import Flask, jsonify, request, abort
import hmac
import hashlib
import logging

# Use ngrok's default logger
log = logging.getLogger("werkzeug")
log.setLevel(logging.INFO)

app = Flask(__name__)

# Validate GitHub webhook
def validate_github_webhook():
    GITHUB_SECRET = b"my_fake_secret"
    signature_header = request.headers.get("X-Hub-Signature-256")
    body = request.data

    if not signature_header:
        abort(400)

    expected_signature = f"sha256={hmac.new(GITHUB_SECRET, body, hashlib.sha256).hexdigest()}"
    if not hmac.compare_digest(expected_signature, signature_header):
        abort(401)

# Handle GitHub open issues event
def open_issues():
    payload = request.get_json()
    action = payload.get("action", "no action")
    repository = payload.get("repository", {})
    repo_name = repository.get("full_name")
    issues_count = repository.get("open_issues_count")
    log.info(f"✅ Repository name: {repo_name} | Open issues: {issues_count}")

# Flask route
@app.route("/github", methods=["POST"])
def github():
    validate_github_webhook()
    
    event_type = request.headers.get("X-GitHub-Event")
    if event_type == "issues":
        open_issues()
    else:
        log.info(f"⚠️ Event not supported: {event_type}")
    
    return "", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
