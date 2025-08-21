from flask import Flask, jsonify, request, abort
import hmac
import hashlib
import logging

# manage Werkzeug's logger
log = logging.getLogger("werkzeug")
log.setLevel(logging.INFO)

app = Flask(__name__)

# validate github webhook
def validate_github_webhook():
    GITHUB_SECRET = b"my_fake_secret"
    signature_header = request.headers.get("X-Hub-Signature-256")
    body = request.data

    if signature_header:
        hash = hmac.new(GITHUB_SECRET, body, hashlib.sha256).hexdigest()
        expected_signature = f"sha256={hash}"
        if not hmac.compare_digest(expected_signature, signature_header):
            abort(401)
    else:
        abort(400)

# simulate github open issues event data
def open_issues():
    payload = request.get_json()
    action = payload.get("action", "no action")
    repository = payload.get("repository", {})
    repo_name = repository.get("full_name")
    issues_count = repository.get("open_issues_count")
    log.info(f"✅ Repository name: {repo_name} | Open issues: {issues_count}")

# simulate new github repository star event data
def star():
    payload = request.get_json()
    action = payload.get("action")
    if action == "created":
        star = payload.get("starred_at")
        log.info(f"✅ This repository was starred")
    elif action == "deleted":
        log.info("❌ This repository was unstarred")
    else:
        log.info(f"⚠️ Unknown star action: {action}")

# create flask route
@app.route("/github", methods=["POST"])
def github():
    # call webhook validation
    validate_github_webhook()

    event_type = request.headers.get("X-GitHub-Event")

    # check if this webhook is for Feature 1
    if event_type == "issues":
        open_issues()

    # check if this webhook is for Feature 2
    elif event_type == "star":
        star()
    else:
        log.info(f"⚠️ Event not supported: {event_type}")

    return "", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
