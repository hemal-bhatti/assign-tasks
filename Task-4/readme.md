NOTE :- 
 we can use secret manager storeing secret insted of store in jenkins secrets.



# CI/CD Pipeline Documentation

---

## a. Pipeline Stages

The pipeline consists of the following stages executed sequentially on a Jenkins agent.

---

### Stage 1 — Checkout

Jenkins pulls the latest source code from the connected Git repository using `checkout scm`. This ensures every build starts from a clean, version-controlled state.

---

### Stage 2 — Fetch Docker Hub Credentials

Docker Hub credentials (username and password) are retrieved securely at runtime and injected as environment variables. In production, this is designed to pull from **AWS Secrets Manager** using the agent's IAM Role, eliminating hardcoded credentials in the codebase.

---

### Stage 3 — Build Docker Image

The application is containerized using the `Dockerfile` present in the repository. The image is tagged with two tags — the Jenkins `BUILD_NUMBER` for traceability and `latest` for convenience.

```
hemal45/simple-node:11     ← versioned (build number)
hemal45/simple-node:latest ← convenience alias
```

---

### Stage 4 — Push to Docker Hub

The Jenkins agent authenticates with Docker Hub using `--password-stdin` (secure, non-interactive login) and pushes both tagged images to the Docker Hub registry. After pushing, it immediately logs out to avoid credential exposure.

---

### Stage 5 — Deploy via SSM Run Command

**AWS Systems Manager (SSM) Run Command** is used to remotely execute a deployment script on the target EC2 instance — without requiring SSH access or open inbound ports.

The deployment command is **base64-encoded** before transmission to avoid shell escaping issues with special characters.

On the EC2 instance, the script:

1. Updates the image tag in `docker-compose.yml` using `sed`
2. Pulls the new image from Docker Hub
3. Restarts the container with `docker compose up -d --remove-orphans`

---

### Post Stage — Cleanup

Regardless of success or failure, the pipeline **always**:

- Removes locally built Docker images from the Jenkins agent
- Wipes the workspace to free disk space

---

## b. Deployment Strategy

The project follows a **Rolling Deployment** strategy using Docker Compose on a single EC2 instance.

### How It Works

- Every push to the `main` branch automatically triggers the Jenkins pipeline via a **GitHub webhook**
- A new Docker image is built and versioned with the Jenkins build number
- The running container on the EC2 instance is updated in-place using `docker compose up -d`, which pulls the new image and restarts only the changed service with **zero manual intervention**
- The `--remove-orphans` flag ensures stale containers from old service definitions are cleaned up automatically

---

## c. Rollback Approach (Conceptual)

Since every build produces a uniquely versioned Docker image tagged with the Jenkins `BUILD_NUMBER`, rolling back is straightforward.

### Step 1 — Identify the Last Stable Build Number

Check Jenkins build history or Docker Hub tags to find the last known good image version.

> **Example:** `hemal45/simple-node:9`

### Step 2 — Trigger Rollback via SSM

Run the following command manually or via a dedicated Jenkins rollback job:

```bash
aws ssm send-command \
  --document-name "AWS-RunShellScript" \
  --instance-ids "i-061c64da266ecc597" \
  --region "ap-south-1" \
  --parameters commands=["cd /var/www/simple-app/simple-backend && \
    sed -i 's|image: hemal45/simple-node:.*|image: hemal45/simple-node:9|g' docker-compose.yml && \
    docker compose pull && \
    docker compose up -d --remove-orphans"]
```

