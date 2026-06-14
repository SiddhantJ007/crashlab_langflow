#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="${LANGFLOW_CONFIG_DIR:-/opt/render/project/src/langflow-data}"
mkdir -p "$DATA_DIR"
mkdir -p /opt/render/project/src/langflow-data

export LANGFLOW_HOST="${LANGFLOW_HOST:-0.0.0.0}"
export LANGFLOW_PORT="${PORT:-${LANGFLOW_PORT:-7860}}"
export LANGFLOW_LOG_LEVEL="${LANGFLOW_LOG_LEVEL:-info}"
export DO_NOT_TRACK="${DO_NOT_TRACK:-true}"

printf 'Starting Langflow backend on %s:%s\n' "$LANGFLOW_HOST" "$LANGFLOW_PORT"

exec python -m langflow run \
  --host "$LANGFLOW_HOST" \
  --port "$LANGFLOW_PORT" \
  --backend-only \
  --no-open-browser \
  --log-level "$LANGFLOW_LOG_LEVEL"
