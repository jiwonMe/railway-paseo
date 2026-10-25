FROM ghcr.io/getpaseo/paseo:latest

# Optional: install common agent CLIs
# Uncomment and customize as needed
# USER root
# RUN npm install -g @anthropic-ai/claude-code @openai/codex opencode-ai || true
# USER paseo

# The base image already runs the daemon and serves the web UI on 0.0.0.0:6767
# Use PASEO_LISTEN=0.0.0.0:$PORT for Railway
