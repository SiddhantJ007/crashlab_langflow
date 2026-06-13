#!/usr/bin/env bash
set -euo pipefail

mkdir -p "${LANGFLOW_CONFIG_DIR:-/opt/render/project/src/langflow-data}"
mkdir -p /opt/render/project/src/langflow-data

export LANGFLOW_HOST="${LANGFLOW_HOST:-0.0.0.0}"
export LANGFLOW_PORT="${PORT:-${LANGFLOW_PORT:-7860}}"

python -m langflow run --host "$LANGFLOW_HOST" --port "$LANGFLOW_PORT"
