# Railway Template for Paseo Daemon

Self-hosted Paseo daemon (coding agent orchestrator) deploy template for Railway.

Paseo lets you orchestrate Claude Code, Codex, OpenCode, Pi and more from desktop, mobile, web and CLI.

## Quick Deploy

1. In Railway, create a new project.
2. Add a service from Docker Image: `ghcr.io/getpaseo/paseo:latest`
3. Set variables:
   - `PASEO_PASSWORD`: a strong password (required)
   - `PASEO_LISTEN`: `0.0.0.0:$PORT`
   - `PASEO_HOSTNAMES`: your Railway domain (e.g. `${{RAILWAY_PUBLIC_DOMAIN}}`)
   - `PASEO_WEB_UI_ENABLED`: `true`
4. Add a Volume mounted at `/home/paseo` (required for persistent state and credentials).
5. Enable Public Networking and generate a domain. Set target port to 6767 or let Railway use `$PORT`.
6. Open the generated domain in a browser and connect with the password.

## Files

- `Dockerfile` — optional custom image that can include agent CLIs
- `railway.toml` — config-as-code example

## Official Docs

- https://paseo.sh/docs/docker
- https://paseo.sh

## Security

Always set `PASEO_PASSWORD`. The daemon is trusted code with access to the host. Only install plugins and agents you trust.
