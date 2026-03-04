#!/usr/bin/env bash
set -euo pipefail

REMOTE_HOST="${1:-devvm-achristensen}"
CONTEXT_NAME="${2:-${REMOTE_HOST}}"
BUILDER_NAME="${3:-${REMOTE_HOST}-container}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required but not installed" >&2
  exit 1
fi

if ! docker buildx version >/dev/null 2>&1; then
  echo "docker buildx is required but not available" >&2
  exit 1
fi

echo "Checking SSH and remote Docker on ${REMOTE_HOST}..."
ssh -o BatchMode=yes -o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new \
  "${REMOTE_HOST}" "docker version --format 'Server={{.Server.Version}}' >/dev/null"

if docker context inspect "${CONTEXT_NAME}" >/dev/null 2>&1; then
  echo "Docker context ${CONTEXT_NAME} already exists"
else
  echo "Creating Docker context ${CONTEXT_NAME} -> ssh://${REMOTE_HOST}"
  docker context create "${CONTEXT_NAME}" --docker "host=ssh://${REMOTE_HOST}" >/dev/null
fi

if docker buildx inspect "${BUILDER_NAME}" >/dev/null 2>&1; then
  echo "Buildx builder ${BUILDER_NAME} already exists"
else
  echo "Creating Buildx builder ${BUILDER_NAME}"
  docker buildx create --name "${BUILDER_NAME}" --driver docker-container --use "${CONTEXT_NAME}" >/dev/null
fi

docker buildx use "${BUILDER_NAME}" >/dev/null
docker buildx inspect "${BUILDER_NAME}" --bootstrap >/dev/null

echo ""
echo "Builder ready: ${BUILDER_NAME}"
echo "Use it with:"
echo "  docker buildx build --builder ${BUILDER_NAME} --platform linux/amd64 -t your-image:tag ."
