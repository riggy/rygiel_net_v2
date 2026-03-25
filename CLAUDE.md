# CLAUDE.md — Project Context for AI Assistants

## Stack

- **Rails 8**, SQLite, Hotwire (Turbo + Stimulus), Importmap, Tailwind v4
- **No npm, no webpack** — use importmap exclusively for JS dependencies
  - Pin packages via `./bin/importmap pin <package>`
  - JS lives in `app/javascript/controllers/` (Stimulus) or pinned CDN packages
- **No Docker, no Kamal** — plain bash deploy via `bin/deploy`

## Markdown & Emoji

All Markdown rendering goes through the `MarkdownParser` concern (`app/presenters/concerns/markdown_parser.rb`). **Do not roll your own renderer.**

- Uses **Redcarpet** for Markdown parsing (autolink, tables, fenced code, strikethrough, superscript)
- Uses **gemoji** to convert `:emoji_name:` → unicode before rendering
- Applied via the presenter pattern — see `PostPresenter`, `NowEntryPresenter`

If you need Markdown rendered somewhere new, include `MarkdownParser` in the relevant presenter.

## Design Tokens (Tailwind v4)

All colours are defined in `app/assets/tailwind/application.css` under `@theme`. Always use these tokens — do not hardcode hex values or invent new classes.

| Token | Usage |
|---|---|
| `bg-bg` | Page background (`#07101f`) |
| `bg-card` | Card / panel background (`#0d1829`) |
| `bg-card-hover` | Card hover state (`#12203a`) |
| `text-surface` | Primary text (`#f0f0f0`) |
| `text-muted` | Secondary text (`#e0e0e0`) |
| `text-subtle` | Tertiary / placeholder text (`#666666`) |
| `text-accent` / `bg-accent` | Electric blue (`#3b82f6`) |
| `text-accent-hover` / `bg-accent-hover` | Accent hover (`#2563eb`) |
| `border-border` | Default border (`#1c2d4a`) |
| `border-border-hover` | Hover border (`#2a4068`) |
| `text-label` | Label/tag text (`#60a5fa`) |

Post body content uses the `.post-body` component class (defined in the same CSS file) — use it for any rendered Markdown output shown to visitors.

## Authentication

Admin area uses **HTTP Basic Auth** — no Devise, no sessions gem. Do not add authentication gems. The existing `authenticate_admin!` before action in `Admin::BaseController` handles it.

## Presenter Pattern

Business logic and rendering live in presenters (`app/presenters/`), not in models or views directly. Each model has a corresponding presenter. Concerns live in `app/presenters/concerns/`.

## Analytics & Visitor Tracking

- `Visitor` — one record per IP, tracks `first_seen_at`, `last_seen_at`, `flagged_at`, `flag_reason`, `flagged_by`
- `PageView` — belongs to `Visitor`, has `trace_id` for correlating server + JS hits
- Rack::Attack is configured in `config/initializers/rack_attack.rb` — it reads flagged IPs from the DB via cache. When adding new throttle rules, follow the existing pattern.

## Deployment

```bash
cp .env.deploy.example .env.deploy  # fill in your values
bin/deploy                           # git pull → bundle → migrate → tailwind → assets → restart puma
```

Puma is managed by systemd (`puma_rygiel_net.service`). Restart is done via `sudo -n /usr/bin/systemctl restart puma_rygiel_net` — the deploy user has a scoped sudoers rule for this only.

## CI Checks

| Check | Tool | What it catches |
|---|---|---|
| `lint` | RuboCop | Style violations — spaces inside array brackets, trailing newlines, etc. |
| `scan_ruby` | Brakeman | Rails security issues — XSS, SQL injection, unsafe `raw`/`html_safe`, mass assignment |
| `scan_js` | importmap audit | JS dependency vulnerabilities |
| `test` | Minitest | Unit + integration tests |
| `system-test` | Minitest + Capybara | Browser-level tests |

**Common RuboCop pitfalls:** spaces inside array literals (`[ "a", "b" ]` not `["a", "b"]`), final newlines in files.

**Brakeman:** avoid `raw`, `html_safe` without explicit sanitization. Use `sanitize()` helper or let `MarkdownParser` handle it.
