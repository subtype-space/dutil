# dutil

A small CLI that wraps common Docker and Docker Compose commands. Less typing, same result.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/subtype-space/dutil/main/install.sh | sudo bash
```

Detects your OS and architecture and installs the appropriate binary to `/usr/local/bin/dutil`. Includes bash completion.

## Commands

| Command | Description |
|---|---|
| `down [file]` | `docker compose down` |
| `log\|logs <name>` | Follow logs for a container |
| `net\|network` | List Docker networks |
| `ps [name]` | List containers, optionally filtered by name |
| `pull [file]` | `docker compose pull` |
| `rebuild [file]` | Build, down, up -d |
| `reload [file]` | Down, up -d |
| `shell <name>` | Open a shell in a container (`/bin/bash` with `/bin/sh` fallback) |
| `up [file]` | `docker compose up` (attached) |
| `upd [file]` | `docker compose up -d` (detached) |
| `upgrade [file]` | Pull, down, up -d |

`[file]` is an optional path to a compose file. If omitted, Docker Compose uses its default discovery.

## Versions

Both a Go binary and the original bash script (`dutil.sh`) are available in releases. The installer pulls the Go binary by default.

## Requirements

- Docker with Compose v2 (`docker compose`)
