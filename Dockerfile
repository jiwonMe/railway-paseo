FROM ghcr.io/getpaseo/paseo:latest

USER root

# Install GitHub CLI and common coding agent CLIs
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | gpg --dearmor -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Install agent CLIs via npm
RUN npm install -g \
    @anthropic-ai/claude-code \
    @openai/codex \
    opencode-ai || true

# Custom entrypoint: fixes volume permissions + prints connection info
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Start as root so the entrypoint can chown the Railway volume
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 6767
