# Changelog

All notable changes to elixirmachine are documented in this file.

## [Unreleased]

### Fixed

- LiveView no longer crashes on partial `validate` / `form_submit` payloads (add-ons **Next**, uncheck all features)
- Wizard **Next** surfaces step validation errors (summary alert + inline field messages) instead of failing silently
- **Next** submits the form so validation uses current field values, not stale server state
- Project step clarifies required output path and lowercase snake_case project name format

### Changed

- Configurator layout aligned with profection module wizard: page title outside card, step icons, 3-segment theme toggle
- Theme loads synchronously before first paint via `phx:theme` / `data-theme-mode` (matches profection-ai)
- Dark theme `base-100` token aligned to profection (`oklch(24% …)`)

### Added

- Spring Initializr–style **step-by-step wizard**: Project → Storage → HTTP/API → Frontend (LiveView) → Add-ons → Review
- Storage step: none / PostgreSQL / ETS (in-memory) for Standalone OTP; locked Postgres on Phoenix types
- HTTP step: API endpoint toggle + optional Finch client; locked API stack on Phoenix API
- New packages: `ecto_ets`, `finch`
- `Wizard` and `Wizard.Sync` modules for step validation and configuration→feature sync
- MCP `list_features` exposes `wizard_steps` metadata

### Changed

- Configurator replaced single-page accordion with linear wizard navigation (Back / Next)
- Add-ons step uses tabbed category picker (Auth, Messaging, Jobs, …)
- Standalone default storage is **none** until user selects on step 2
- `configuration.storage_backend` and `http_client` drive dependency resolution
- Ash only offered when PostgreSQL storage is selected

### Added (prior unreleased)

- Profection-aligned configurator UI: Ubuntu Sans, OKLCH daisyUI themes, dashed focus states, app shell header with theme toggle
- Explicit selectable dependency packages: `ecto_postgres`, `ash`, `daisy_ui`, `petal_ui` as checkboxes per section
- `EctoPostgres` and `OtpScaffold` feature modules replacing implicit `BasePostgres`
- Locked `ecto_postgres` inclusion for Phoenix API and Phoenix LiveView project types
- Standalone OTP defaults `include_database` to on with auto-preselect of `ecto_postgres`

### Changed

- LiveView UI selection uses feature checkboxes instead of `configuration.ui_framework` radio buttons
- Database section shows locked included packages on Phoenix types and selectable Ecto/Ash on Standalone OTP
- Configurator uses app layout with centered wizard column (`max-w-3xl`) instead of custom full-page shell
- MCP `configuration_schema` no longer exposes `ui_framework`
- Ash and scaffold modules require `ecto_postgres` instead of implicit `postgres` id

### Added (prior unreleased)

- Sectioned configurator UI: Database, API, LiveView/frontend, Auth, Messaging, Jobs, Search, AI, Code quality, Dev tools
- Phoenix API project type with JSON API scaffold
- Petal Components UI framework option (mutually exclusive with daisyUI)
- Code quality packages: Credo, Sobelow, ExCoveralls, Mix Audit with auto-config in build scripts
- `DepCatalog` and `SectionVisibility` modules seeded from profection reference projects
- `generations.configuration` map for section toggles and UI framework selection
- RabbitMQ package wired to `amqp` via Igniter
- Package selection with optional checkboxes filtered by project type
- Required-additions consent panel: transitive dependencies shown as pre-checked boxes that must stay checked to generate
- Resolved package summary chips in the configurator
- Stub packages (RabbitMQ, Elasticsearch, Solr, MS AD) visible as disabled “Coming soon” rows
- `Catalog.packages_for/1` and `Catalog.resolve_selection/3` for shared UI and MCP resolution
- MCP `create_generation` auto-accepts implied dependencies when `accepted_required` is omitted

### Changed

- Ash install commands: standalone OTP uses `ash ash_postgres` only; Phoenix adds `ash_phoenix`
- Phoenix LiveView project type hides redundant LiveView optional checkbox (scaffold included implicitly)
- `generations.features` stores user-selected optional package IDs only; expansion happens at script build time
- Credo: alphabetized aliases in `Generations`, aliased nested modules in `CoreComponents` and `DataCase`

### Added (initial release)

- Initial Phoenix LiveView configurator with daisyUI styling
- Hybrid Igniter + EEx generator for Elixir + Postgres base projects
- Optional features: LiveView, daisyUI, Ash (RabbitMQ, Elasticsearch, Solr, MS AD stubs)
- Downloadable build scripts for macOS (`.sh`) and Windows (`.bat`)
- Per-generation API keys for MCP tool authentication
- Anubis MCP server at `/mcp` with tools: `list_features`, `create_generation`, `get_script`, `get_status`
- Docker Compose deployment with Postgres metadata database
- Example Cursor MCP configuration (`.cursor/mcp.json.example`)
- Credo for static code analysis (dev/test)
- Credo-driven refactors in generations, generation validation, configurator, and download controller

## [0.1.0] - 2025-06-12

- Project scaffold
