FROM ghcr.io/getpaseo/paseo:latest

USER root

# Install common coding agent CLIs
RUN npm install -g \
    @anthropic-ai/claude-code \
    @openai/codex \
    opencode-ai || true

# Copy and set entrypoint that fixes /home/paseo permissions
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Start as root so the entrypoint can chown the Railway volume
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 6767
