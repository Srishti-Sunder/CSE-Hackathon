#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"
python -m pip install -r backend/requirements.txt
npm --prefix frontend install

export SECRET_KEY="${SECRET_KEY:-p13-replit-demo-secret-change-before-deployment}"
export PORT=5000
python backend/app.py &
BACKEND_PID=$!
trap 'kill "$BACKEND_PID" 2>/dev/null || true' EXIT

cd frontend
npm run dev -- --host 0.0.0.0
