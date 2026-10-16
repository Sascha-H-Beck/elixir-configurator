# elixirmachine

Elixir project configurator with a web UI and Cursor MCP integration. Configure project type, optional features, and target OS — then download a build script for your local machine.

**Base stack (always included):** Elixir + PostgreSQL (when database is enabled)  
**Project types:** Standalone OTP, Phoenix API, Phoenix LiveView  
**Sections:** Database, API, LiveView/frontend (daisyUI or Petal), Auth, Messaging, Jobs, Search, AI, Code quality, Dev tools

## Quick start (Docker)

```bash
docker compose up --build
```

Open the configurator: [http://127.0.0.1:4000](http://127.0.0.1:4000)

Postgres for generation metadata runs on host port **5433**.

## Web UI workflow

1. Set project name, type (Standalone OTP, Phoenix API, or Phoenix LiveView), target OS, and output path.
2. Configure section toggles (database, API, UI framework, code quality tools).
3. Click **Generate** — copy the API key (shown once per generation).
4. Download the `.sh` (macOS) or `.bat` (Windows) script.
5. Run the script locally in a terminal — it scaffolds the project at the configured path.

## Cursor MCP

Add to `.cursor/mcp.json` (see `.cursor/mcp.json.example`):

```json
{
  "mcpServers": {
    "elixirmachine": {
      "url": "http://127.0.0.1:4000/mcp",
      "headers": {
        "Authorization": "Bearer ${env:ELIXIRMACHINE_GENERATION_KEY}"
      }
    }
  }
}
```

### MCP tools

| Tool | Auth | Description |
|---|---|---|
| `list_features` | None | Feature catalog |
| `create_generation` | None | Create generation; returns `generation_id` + `api_key` |
| `get_script` | Per-generation API key | Download script content |
| `get_status` | Per-generation API key | Generation status |

**Typical MCP flow:**

1. Call `create_generation` with explicit `output_path` → receive `api_key`.
2. Set `ELIXIRMACHINE_GENERATION_KEY` or pass `api_key` in tool args.
3. Call `get_script` with `generation_id`.
4. Save and run the script on your local machine.

Use `127.0.0.1` instead of `localhost` if Cursor cannot connect (IPv6 issues).

Debug MCP via Cursor **Output → MCP Logs**.

## Local development

Requires Elixir **1.18+** (see `.tool-versions`).

```bash
mix setup
mix phx.server
```

## Requirements

- Docker Desktop (for containerized configurator)
- Elixir + Mix on host (for running generated scripts)
- Optional: Docker on host (generated projects include docker-compose)
