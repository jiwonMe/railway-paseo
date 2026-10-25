#!/bin/sh
set +e

echo "=== Paseo Railway Entrypoint ==="

# Ensure home exists and is owned by paseo
if [ -d /home/paseo ]; then
  echo "Fixing permissions on /home/paseo ..."
  chown -R paseo:paseo /home/paseo 2>/dev/null || true
  chmod -R u+rwX /home/paseo 2>/dev/null || true
fi
mkdir -p /home/paseo/.paseo
chown -R paseo:paseo /home/paseo/.paseo 2>/dev/null || true

# Apply Railway-friendly defaults if not set
export PASEO_LISTEN="${PASEO_LISTEN:-0.0.0.0:${PORT:-6767}}"
export PASEO_WEB_UI_ENABLED="${PASEO_WEB_UI_ENABLED:-true}"

if [ -n "$RAILWAY_PUBLIC_DOMAIN" ] && [ -z "$PASEO_HOSTNAMES" ]; then
  export PASEO_HOSTNAMES="$RAILWAY_PUBLIC_DOMAIN"
  echo "Set PASEO_HOSTNAMES=$PASEO_HOSTNAMES"
fi

if [ -z "$PASEO_TRUSTED_PROXIES" ]; then
  export PASEO_TRUSTED_PROXIES="true"
fi

# Optional: load keys saved by auth-helper
if [ -f /home/paseo/.paseo/.env.auth ]; then
  echo "Loading keys from .env.auth"
  set -a
  . /home/paseo/.paseo/.env.auth
  set +a
fi

# Install Connect plugin if present in the image
if [ -d /opt/paseo-connect ]; then
  echo "Installing Paseo Connect plugin..."
  su -s /bin/sh paseo -c "paseo plugin install /opt/paseo-connect --id paseo-connect" || \
    echo "(plugin install failed or already installed)"
fi

echo "Starting Paseo daemon..."

ORIG=""
if [ -x /usr/local/bin/paseo-docker-entrypoint ]; then
  ORIG="/usr/local/bin/paseo-docker-entrypoint"
elif [ -x /entrypoint.sh ]; then
  ORIG="/entrypoint.sh"
fi

if [ -n "$ORIG" ]; then
  "$ORIG" "$@" &
else
  # Fallback
  su -s /bin/sh paseo -c "paseo daemon run --listen $PASEO_LISTEN --web-ui" &
fi
DAEMON_PID=$!

echo "Daemon PID: $DAEMON_PID"
echo "Waiting for daemon (up to 2 min)..."
READY=0
for i in $(seq 1 60); do
  if wget -q -O /dev/null --timeout=2 http://127.0.0.1:6767/api/health 2>/dev/null || \
     curl -sf --max-time 2 http://127.0.0.1:6767/api/health >/dev/null 2>&1; then
    echo "Daemon is ready."
    READY=1
    break
  fi
  sleep 2
done

if [ "$READY" -eq 0 ]; then
  echo "Warning: health check timed out."
fi

echo ""
echo "========================================"
echo "  Paseo Connection Info"
echo "========================================"
echo ""

if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  echo "Web UI:"
  echo "  https://$RAILWAY_PUBLIC_DOMAIN"
  echo ""
  echo "Direct connection:"
  echo "  Host: $RAILWAY_PUBLIC_DOMAIN"
  echo "  Port: 443 (SSL)"
  echo ""
else
  echo "No RAILWAY_PUBLIC_DOMAIN. Generate a public domain in Railway."
  echo ""
fi

if [ -n "$PASEO_PASSWORD" ]; then
  echo "Password: (set via PASEO_PASSWORD)"
else
  echo "WARNING: PASEO_PASSWORD is not set."
fi
echo ""

echo "Pairing (relay):"
if command -v su >/dev/null 2>&1; then
  su -s /bin/sh paseo -c "paseo daemon pair --relay 2>&1" || echo "(pair failed — try later)"
else
  paseo daemon pair --relay 2>&1 || true
fi

echo ""
echo "Connect plugin: open the Connect item in the sidebar after login."
echo "========================================"
echo ""

wait $DAEMON_PID
