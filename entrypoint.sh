#!/bin/bash
set -e

echo "[entrypoint] Starting OpenClaw Railway wrapper..."

mkdir -p "${OPENCLAW_STATE_DIR:-/data/.openclaw}"
mkdir -p "${OPENCLAW_WORKSPACE_DIR:-/data/workspace}"
chown -R openclaw:openclaw /data 2>/dev/null || true

CONFIG_DIR="${OPENCLAW_STATE_DIR:-/data/.openclaw}"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
  node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
    if (!cfg.gateway) cfg.gateway = {};
    if (!cfg.gateway.controlUi) cfg.gateway.controlUi = {};
    cfg.gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback = true;
    cfg.gateway.controlUi.requireDevicePairing = false;
    cfg.gateway.controlUi.pairingRequired = false;
    if (!cfg.gateway.auth) cfg.gateway.auth = {};
    cfg.gateway.auth.controlUiPairingRequired = false;
    fs.writeFileSync('$CONFIG_FILE', JSON.stringify(cfg, null, 2));
    console.log('[entrypoint] Patched config');
  "
else
  echo '{"gateway":{"controlUi":{"dangerouslyAllowHostHeaderOriginFallback":true,"requireDevicePairing":false,"pairingRequired":false},"auth":{"controlUiPairingRequired":false}}}' > "$CONFIG_FILE"
  echo "[entrypoint] Created openclaw.json"
fi

chown openclaw:openclaw "$CONFIG_FILE" 2>/dev/null || true
exec gosu openclaw node src/server.js
