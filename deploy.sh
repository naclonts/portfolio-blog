#!/usr/bin/env bash
#
# Build the site in production mode and deploy it via rsync.
#
# Usage: ./deploy.sh [--dry-run]
#
# Flags:
#   --dry-run   Pass --dry-run to rsync (shows what would change, writes nothing)

set -euo pipefail
cd "$(dirname "$0")"

REMOTE_DIR="/var/www/portfolio-blog/"

# Ask where to deploy; DEPLOY_TARGET=you@example.com ./deploy.sh skips the prompt.
if [[ -n "${DEPLOY_TARGET:-}" ]]; then
  REMOTE="$DEPLOY_TARGET"
else
  read -r -p "Deploy to (user@host): " REMOTE
  if [[ -z "$REMOTE" ]]; then
    echo "ERROR: no deploy target given." >&2
    exit 1
  fi
fi

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dry-run"
fi

# gatsby develop also writes into public/ (dev artifacts, no HTML pages).
# Deploying that is exactly the bug that caused the 403 incident, so refuse.
if lsof -i :8000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "ERROR: gatsby develop is listening on :8000 — it overwrites public/ with dev artifacts." >&2
  echo "Stop it first (e.g. 'pkill -f gatsby.develop'), then run ./deploy.sh again." >&2
  exit 1
fi

echo "==> Cleaning and building..."
npx gatsby clean
npx gatsby build

# Guard against deploying anything that isn't a complete production build.
if [[ ! -f public/index.html ]]; then
  echo "ERROR: public/index.html is missing — build did not produce a deployable site." >&2
  exit 1
fi
# Every post should have a rendered index.html directly under public/.
expected_pages=$(find content/blog -mindepth 1 -maxdepth 1 -type d | wc -l)
actual_pages=$(find public -mindepth 2 -maxdepth 2 -name index.html ! -path '*/page-data/*' | wc -l)
if [[ "$actual_pages" -lt "$expected_pages" ]]; then
  echo "ERROR: expected at least $expected_pages post pages, found $actual_pages — build looks incomplete." >&2
  exit 1
fi

echo "==> Syncing public/ to $REMOTE:$REMOTE_DIR ${DRY_RUN}"
rsync -avz --delete --itemize-changes $DRY_RUN public/ "$REMOTE:$REMOTE_DIR"

echo "==> Done. Deployed to $REMOTE_DIR on $REMOTE"
