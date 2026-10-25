#!/bin/sh
set -e

# Fix Railway volume permissions (volume is mounted as root)
if [ -d "/home/paseo" ]; then
  echo "Fixing permissions on /home/paseo ..."
  chown -R paseo:paseo /home/paseo 2>/dev/null || true
  chmod -R u+rwX /home/paseo 2>/dev/null || true
fi

# Start the original Paseo entrypoint in the background
/usr/local/bin/paseo-docker-entrypoint "$@" &
DAEMON_PID=$!

# Wait for the daemon to become healthy
echo "Waiting for Paseo daemon to be ready..."
for i in $(seq 1 60); do
  if wget -q -O /dev/null http://127.0.0.1:6767/api/health 2>/dev/null; then
    echo "Daemon is ready."
    break
  fi
  sleep 2
done

echo ""
echo "========================================"
echo "  Paseo Connection Info"
echo "========================================"
echo ""

# Print web UI link if domain is available
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  echo "Web UI:"
  echo "  https://$RAILWAY_PUBLIC_DOMAIN"
  echo ""
fi

# Generate and print pairing QR / link
echo "Pairing QR & Link (scan with Paseo mobile app):"
echo ""

# Try to enable relay and print QR
if command -v su >/dev/null 2>&1; then
  su -s /bin/sh paseo -c "paseo daemon pair --relay --json 2>/dev/null || paseo daemon pair --relay 2>/dev/null || echo 'Could not generate pairing info yet. Run: paseo daemon pair --relay'" || true
else
  paseo daemon pair --relay --json 2>/dev/null || paseo daemon pair --relay 2>/dev/null || echo "Could not generate pairing info yet."
fi

echo ""
echo "========================================"
echo "  End of Connection Info"
echo "========================================"
echo ""

# Keep the container running by waiting for the daemon
wait $DAEMON_PID
