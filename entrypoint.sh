#!/bin/sh
set +e

echo "=== Paseo Railway Entrypoint ==="
echo "Fixing permissions on /home/paseo ..."
if [ -d /home/paseo ]; then
  chown -R paseo:paseo /home/paseo 2>/dev/null || true
  chmod -R u+rwX /home/paseo 2>/dev/null || true
fi
mkdir -p /home/paseo/.paseo
chown -R paseo:paseo /home/paseo/.paseo 2>/dev/null || true

echo "Starting Paseo daemon..."

# Try common entrypoint locations
if [ -x /usr/local/bin/paseo-docker-entrypoint ]; then
  /usr/local/bin/paseo-docker-entrypoint "$@" &
elif [ -x /entrypoint.sh ]; then
  /entrypoint.sh "$@" &
elif command -v paseo >/dev/null 2>&1; then
  # Fallback: run daemon directly
  su -s /bin/sh paseo -c "paseo daemon run --listen 0.0.0.0:6767 --web-ui" &
else
  echo "ERROR: Could not find Paseo entrypoint or binary"
  exit 1
fi
DAEMON_PID=$!

echo "Daemon PID: $DAEMON_PID"
echo "Waiting for daemon to be ready (up to 2 minutes)..."
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
  echo "Warning: Daemon health check timed out. Continuing anyway..."
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
else
  echo "Web UI: (set RAILWAY_PUBLIC_DOMAIN or check Railway networking)"
  echo ""
fi

echo "Pairing info (enable relay first with PASEO_RELAY_ENABLED=true):"
echo ""

if command -v su >/dev/null 2>&1; then
  su -s /bin/sh paseo -c "paseo daemon pair --relay 2>&1" || echo "(pair command failed — try manually later)"
else
  paseo daemon pair --relay 2>&1 || echo "(pair command failed)"
fi

echo ""
echo "========================================"
echo "  End of Connection Info"
echo "========================================"
echo ""

# Wait for the daemon process
wait $DAEMON_PID
