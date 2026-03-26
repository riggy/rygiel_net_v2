# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Rails 8.1 personal blog/portfolio site. Three core models: `Post` (blog articles), `Project` (portfolio items), `NowEntry` ("Now" page content). Server-rendered ERB with Hotwire (Turbo + Stimulus). SQLite + Solid Suite (Cache, Queue, Cable) — no Redis, no Docker, no Kamal.

## Commands

```bash
bin/setup               # Install dependencies & prepare database
bin/dev                 # Start development server
bundle exec rspec       # Run all specs
bundle exec rspec <file> # Run a single spec file
bin/rubocop             # Lint Ruby code
bin/brakeman --no-pager # Security scan
bin/ci                  # Full CI pipeline (lint + security + tests)
bin/deploy              # Deploy: git pull → bundle → migrate → assets → restart puma
```

## Pre-PR Checklist

Run before every push: `bin/brakeman --no-pager && bin/bundler-audit && bin/rubocop && bundle exec rspec`

Don't rely on GitHub Actions to catch these.

## Architecture

**No npm, no webpack** — Importmap exclusively for JS. Pin packages via `bin/importmap pin <package>`, always use the `.esm.js` CDN build (UMD/CJS bundles throw `SyntaxError` with importmap). Propshaft, not Sprockets.

**Frontend:** Stimulus controllers in `app/javascript/controllers/`. Turbo handles navigation — avoid custom fetch/XHR where Turbo frames/streams work.

**Stimulus controllers:**
- `markdown-editor` — admin Markdown editor with `:emoji:` autocomplete via TributeJS; fetches `/admin/emojis.json` at connect time
- `page-tracker` — fires `POST /page_views` on every `turbo:load` / `hashchange` (deduped); reads `csrf-token` and `trace-id` from `<meta>` tags

**Backend:** Presenters (`app/presenters/`) handle rendering — not models or views directly. Each model has a presenter; concerns in `app/presenters/concerns/`.

**Jobs:** Solid Queue runs inside Puma — no separate worker process.

## Markdown & Emoji

All rendering goes through `MarkdownParser` (`app/presenters/concerns/markdown_parser.rb`). Do not roll your own renderer. Uses Redcarpet + gemoji. Include `MarkdownParser` in any presenter that needs it.

## Design Tokens (Tailwind v4)

Defined in `app/assets/tailwind/application.css` under `@theme`. Always use tokens — never hardcode hex values.

Key tokens: `bg-bg`, `bg-card`, `bg-card-hover`, `text-surface`, `text-muted`, `text-subtle`, `text-accent`, `text-accent-hover`, `border-border`, `border-border-hover`, `text-label`. See the CSS file for values.

Use `.post-body` for any rendered Markdown shown to visitors.

## Authentication

Admin: HTTP Basic Auth only — no Devise, no sessions gem. `authenticate_admin!` in `Admin::BaseController`. In request specs, stub `Rails.application.credentials.dig(:admin, :username/password)` — no master key in CI.

## Analytics & Visitor Tracking

- `Visitor` — one record per IP (`first_seen_at`, `last_seen_at`, `flagged_at`, `flag_reason`)
- `PageView` — belongs to `Visitor`, has `trace_id`
- Rack::Attack reads flagged IPs from DB via cache — follow existing pattern in `config/initializers/rack_attack.rb`

## Git Workflow

**Never commit to `main` directly.** Branch → PR → review → merge.

- Branch naming: `feature/<short-description>`
- Use `gh pr create` to open PRs

**RuboCop pitfalls:** spaces inside array literals (`[ "a", "b" ]`), final newlines in files.
**Brakeman:** avoid `raw`/`html_safe` without sanitization; use `sanitize()` or `MarkdownParser`.

## General Rules

Do not create scratch or planning files in the project directory. Think silently or use code comments. Delete any temporary files you create.
