#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="${1:-devvm-achristensen}"

echo "Running remote BuildKit preflight on ${REMOTE_HOST}..."

ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
  "${REMOTE_HOST}" 'bash -s' <<'EOF'
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed on remote host" >&2
  exit 1
fi

echo "Remote host: $(hostname)"
docker version --format 'Server={{.Server.Version}}'
docker info >/dev/null

if docker image inspect moby/buildkit:buildx-stable-1 >/dev/null 2>&1; then
  echo "BuildKit image already present"
else
  echo "Pulling BuildKit image..."
  docker pull moby/buildkit:buildx-stable-1 >/dev/null
fi

echo "Remote BuildKit preflight complete"
EOF
