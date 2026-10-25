FROM ghcr.io/getpaseo/paseo:latest

USER root

# Install common coding agent CLIs
RUN npm install -g \
    @anthropic-ai/claude-code \
    @openai/codex \
    opencode-ai || true

# Base image switches back to the paseo user and starts the daemon
# Web UI + daemon listen on 0.0.0.0:6767

EXPOSE 6767
