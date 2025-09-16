#!/usr/bin/env bash
set -euo pipefail

# Simple deployment script for server (Oracle Linux/Ubuntu, etc.)
# - pulls latest code
# - builds jars with Maven
# - rebuilds Docker images and restarts services via Docker Compose

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
COMPOSE_FILE="$REPO_DIR/easyshop-infra/docker-compose.yml"

SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-docker}
MVN_ARGS=${MVN_ARGS:-"-T 1C -DskipTests"}

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  else
    docker-compose "$@"
  fi
}

echo "==> Switching to repo: $REPO_DIR"
cd "$REPO_DIR"

if [ -d .git ]; then
  echo "==> Fetching latest changes"
  git fetch --all --prune
  git pull --rebase --autostash || true
fi

if [ ! -f easyshop-infra/.env ] && [ -f easyshop-infra/.env.example ]; then
  echo "==> Seeding easyshop-infra/.env from example"
  cp easyshop-infra/.env.example easyshop-infra/.env
fi

echo "==> Building backend jars with Maven ($MVN_ARGS)"
mvn -q -f easyshop-parent/pom.xml clean package $MVN_ARGS

echo "==> Building and deploying containers"
compose -f "$COMPOSE_FILE" up -d --build

echo "==> Pruning dangling images"
docker image prune -f >/dev/null 2>&1 || true

echo "==> Services status"
compose -f "$COMPOSE_FILE" ps

echo "\nDeployment done."

