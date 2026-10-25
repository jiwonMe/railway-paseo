# Railway Template for Paseo

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/)

Self-hosted Paseo daemon with agent CLIs (Claude Code, Codex, OpenCode) and GitHub CLI, optimized for Railway.

## Features

- Official Paseo image + pre-installed agents
- Auto-fix volume permissions on startup
- Connection info + pairing link printed to Deploy Logs
- Healthcheck at `/api/health`
- Recommended variables using Railway reference syntax

## Quick Start (Template)

1. Click the Deploy button above (or deploy this repo).
2. Railway will ask for variables. Recommended:
   - `PASEO_PASSWORD` = `${{secret(32)}}` (auto-generated)
   - `PASEO_HOSTNAMES` = `${{RAILWAY_PUBLIC_DOMAIN}}`
   - `PASEO_TRUSTED_PROXIES` = `true`
3. Attach a Volume mounted at `/home/paseo`.
4. Generate a public domain (target port 6767).
5. Open the domain and log in with the password.

## Variables

| Variable | Recommended Value | Purpose |
|----------|-------------------|---------|
| `PASEO_PASSWORD` | `${{secret(32)}}` | Daemon password |
| `PASEO_HOSTNAMES` | `${{RAILWAY_PUBLIC_DOMAIN}}` | Allowlist for the public domain |
| `PASEO_TRUSTED_PROXIES` | `true` | Trust Railway proxy headers |
| `PASEO_LISTEN` | `0.0.0.0:${{PORT}}` | Bind address |
| `ANTHROPIC_API_KEY` | (optional) | Claude Code |
| `OPENAI_API_KEY` | (optional) | Codex |
| `GH_TOKEN` | (optional) | GitHub CLI |

## After Deploy

- Check **Deploy Logs** for the Web UI URL and pairing QR/link.
- Volume at `/home/paseo` persists state and agent credentials across restarts.

## Files

- `Dockerfile` — agents + gh + custom entrypoint
- `entrypoint.sh` — permission fix + connection info
- `railway.toml` — config as code
- `auth-helper/` — authentication guidance page

## Official Docs

- https://paseo.sh
- https://paseo.sh/docs/docker
