#!/bin/sh
set -e

# Always print something immediately so it shows in Railway logs
echo ""
echo "========================================"
echo "  Paseo starting on Railway"
echo "========================================"

if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  echo "Web UI: https://$RAILWAY_PUBLIC_DOMAIN"
else
  echo "Web UI: (set RAILWAY_PUBLIC_DOMAIN or open the public domain)"
fi

echo "Password: (from PASEO_PASSWORD variable)"
echo ""

# Fix volume permissions if running as root
if [ -d "/home/paseo" ] && [ "$(id -u)" = "0" ]; then
  echo "Fixing permissions on /home/paseo ..."
  chown -R paseo:paseo /home/paseo 2>/dev/null || true
fi

# Try to print pairing info in the background after a delay
(
  sleep 15
  echo ""
  echo "========== Pairing Info =========="
  if command -v paseo >/dev/null 2>&1; then
    paseo daemon pair --relay 2>&1 || echo "(Pairing not ready yet. Run 'paseo daemon pair --relay' in shell)"
  else
    echo "paseo CLI not found"
  fi
  echo "=================================="
  echo ""
) &

# Exec the original Paseo entrypoint (pass through all arguments)
# The base image entrypoint handles dropping privileges and starting the daemon
if [ -x /usr/local/bin/paseo-docker-entrypoint ]; then
  exec /usr/local/bin/paseo-docker-entrypoint "$@"
elif command -v paseo >/dev/null 2>&1; then
  exec paseo daemon run "$@"
else
  echo "Could not find Paseo entrypoint"
  exec "$@"
fi
