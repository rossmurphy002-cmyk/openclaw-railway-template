#!/bin/bash
set -e

# Ensure /data is owned by openclaw user and has restricted permissions
chown openclaw:openclaw /data 2>/dev/null || true
chmod 700 /data 2>/dev/null || true

# Persist Homebrew to Railway volume so it survives container rebuilds
BREW_VOLUME="/data/.linuxbrew"
BREW_SYSTEM="/home/openclaw/.linuxbrew"

if [ -d "$BREW_VOLUME" ]; then
  # Volume already has Homebrew — symlink back to expected location
  if [ ! -L "$BREW_SYSTEM" ]; then
    rm -rf "$BREW_SYSTEM"
    ln -sf "$BREW_VOLUME" "$BREW_SYSTEM"
    echo "[entrypoint] Restored Homebrew from volume symlink"
  fi
else
  # First boot — move Homebrew install to volume for persistence
  if [ -d "$BREW_SYSTEM" ] && [ ! -L "$BREW_SYSTEM" ]; then
    mv "$BREW_SYSTEM" "$BREW_VOLUME"
    ln -sf "$BREW_VOLUME" "$BREW_SYSTEM"
    echo "[entrypoint] Persisted Homebrew to volume on first boot"
  fi
fi
#!/bin/bash
set -e

# Ensure /data is owned by openclaw user and has restricted permissions
chown openclaw:openclaw /data 2>/dev/null || true
chmod 700 /data 2>/dev/null || true

# Persist Homebrew to Railway volume so it survives container rebuilds
BREW_VOLUME="/data/.linuxbrew"
BREW_SYSTEM="/home/openclaw/.linuxbrew"

if [ -d "$BREW_VOLUME" ]; then
  # Volume already has Homebrew — symlink back to expected location
    if [ ! -L "$BREW_SYSTEM" ]; then
        rm -rf "$BREW_SYSTEM"
            ln -sf "$BREW_VOLUME" "$BREW_SYSTEM"
                echo "[entrypoint] Restored Homebrew from volume symlink"
                  fi
                  else
                    # First boot — move Homebrew install to volume for persistence
                      if [ -d "$BREW_SYSTEM" ] && [ ! -L "$BREW_SYSTEM" ]; then
                          mv "$BREW_SYSTEM" "$BREW_VOLUME"
                              ln -sf "$BREW_VOLUME" "$BREW_SYSTEM"
                                  echo "[entrypoint] Persisted Homebrew to volume on first boot"
                                    fi
                                    fi

                                    # Patch OpenClaw config to allow Railway public domain origin for Control UI
                                    # This fixes the "origin not allowed" error when accessing via Railway's public URL
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
                                                              fs.writeFileSync('$CONFIG_FILE', JSON.stringify(cfg, null, 2));
                                                                  console.log('[entrypoint] Patched openclaw.json with origin fallback');
                                                                    "
                                                                    else
                                                                      echo '{"gateway":{"controlUi":{"dangerouslyAllowHostHeaderOriginFallback":true}}}' > "$CONFIG_FILE"
                                                                        echo "[entrypoint] Created openclaw.json with origin fallback"
                                                                        fi
                                                                        chown openclaw:openclaw "$CONFIG_FILE" 2>/dev/null || true

                                                                        exec gosu openclaw node src/server.js
exec gosu openclaw node src/server.js
