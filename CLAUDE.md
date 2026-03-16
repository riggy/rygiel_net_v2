# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Rails 8.1 personal blog/portfolio site. Three core models: `Post` (blog articles), `Project` (portfolio items), `NowEntry` ("Now" page content). Server-rendered ERB with Hotwire (Turbo + Stimulus). SQLite + Solid Suite (Cache, Queue, Cable) — no Redis or external job queue.

## Commands

```bash
bin/setup          # Install dependencies & prepare database
bin/dev            # Start development server
bin/rails test     # Run all unit/integration tests
bin/rails test:system  # Run browser tests (requires Chrome)
bin/rails test test/models/post_test.rb  # Run a single test file
bin/rubocop        # Lint Ruby code
bin/brakeman       # Security scan
bin/ci             # Full CI pipeline (lint + security + tests)
```

## Architecture

**Frontend:** Stimulus controllers live in `app/javascript/controllers/`. Turbo handles navigation — avoid writing custom fetch/XHR where Turbo frames/streams can be used instead.

**Backend:** Fat routes + thin models pattern expected. Controllers inherit from `ApplicationController` which enforces modern browser requirements (WebP, CSS nesting, Web Push support).

**Database:** Multi-database setup in production — primary (`production.sqlite3`), cache (`production_cache.sqlite3`), queue (`production_queue.sqlite3`). Migrations go to the primary DB by default.

**Jobs:** Solid Queue runs inside Puma in production (single-server model). No separate worker process needed for deployment.

**Assets:** Propshaft (not Sprockets) + Importmap (no Node/webpack). Add JS packages via `bin/importmap pin <package>`.

## Deployment

Kamal deploys to a Docker container. Secrets managed via `config/master.key` (never commit). Deploy with `bin/kamal deploy`.

## CI

GitHub Actions runs: security scan (Brakeman) → JS audit → lint (RuboCop) → unit tests → system tests. Lint failures block merge. System test screenshots on failure are uploaded as artifacts.