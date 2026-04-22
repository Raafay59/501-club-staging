# TAMU Ideathon Technical Documentation

This document describes the **501-plan** Rails application: architecture, configuration, testing, and deployment. For organizer-facing steps, see **`docs/user_documentation.md`**. For a concise map of dashboard vs public code, see **`docs/admin_dashboard_system_guide.md`**.

---

## Stack

| Layer | Technology |
|-------|----------------|
| Framework | Ruby on Rails **8.1** (see `Gemfile`) |
| Language | Ruby **3.4.6** (`.ruby-version`) |
| Database | PostgreSQL |
| Web server | Puma (`config/puma.rb`, binds `PORT`) |
| Assets | Propshaft, Tailwind (`tailwindcss-rails`), importmap (no Node required for production build) |
| Auth | Devise (`Admin`) + OmniAuth **Google OAuth2** |
| UI | Turbo, Stimulus |
| Background jobs (production) | **Solid Queue** (DB-backed); optional `SOLID_QUEUE_IN_PUMA` to run the supervisor inside Puma |
| Cache / cable (production) | **Solid Cache** / **Solid Cable** (see `config/environments/production.rb`) |

Development uses **memory** cache and async-friendly defaults; production uses Solid adapters and multiple logical DB roles that all share **`DATABASE_URL`** on Heroku (see `config/database.yml`).

---

## Repository layout (high level)

| Path | Role |
|------|------|
| `app/controllers/ideathon_controller.rb` | Public landing |
| `app/views/ideathon/` | Public templates |
| `app/controllers/registered_attendees_controller.rb` | Public registration |
| `app/controllers/manager_controller.rb` | Organizer registration dashboard |
| `app/controllers/ideathon_events_controller.rb` | Schedule CRUD (not under `/dashboard`) |
| `app/controllers/*` under dashboard pattern | Content modules scoped to `/dashboard` |
| `app/controllers/club_dashboard_controller.rb` | Base auth for dashboard modules |
| `app/services/active_ideathon_year.rb` | Resolves which `IdeathonYear` drives public content |
| `docs/` | Markdown copies of documentation (in-app nav serves **`public/*.pdf`**) |
| `script/` | Local Postgres helpers (`start-db`, `stop-db`, `app-start`) — see `script/ReadMe.md` |
| `Procfile` | Heroku: `web`, `worker`, `release` (migrate + seed) |

---

## Routes (summary)

- **Public:** `GET /` → `ideathon#index`
- **Docs (PDFs):** `GET /UserDocumentation.pdf`, `GET /TechnicalDocumentation.pdf` — static files from **`public/`** (same as `501-club-staging`; no controller)
- **Admin Devise:** `devise_for :admins`, custom `admins/sign_in`, `admins/sign_out`
- **Manager:** `resources :manager` → index, destroy, export_participants, export_teams, view_pdf
- **Events:** `resources :ideathon_events`
- **Registration:** `resources :registered_attendees` (+ `teams_for_year`, `success`)
- **Dashboard:** `scope path: "dashboard"` → users, activity_logs, ideathons, sponsors_partners, mentors_judges, faqs, rules
- **Health:** `GET /up` → Rails health check

Full list: `bin/rails routes`.

---

## Authentication and authorization

- **`Admin`** model: Devise **omniauthable** (Google only in practice). Roles: `admin`, `editor`, `unauthorized` (string-backed enum).
- **`ApplicationController`**
  - `authenticate_admin!` except **`public_page?`** (home + specific `registered_attendees` actions).
  - `require_organizer_tools!` unless Devise or public — redirects unauthorized roles away from organizer tools.
  - Helpers: `admin?`, `editor?`, `organizer_tools?` (`authorized?` = not `unauthorized`).
- **`ClubDashboardController`** — dashboard base: must be logged in and **authorized** for dashboard tools.
- **`UsersController`** and selected actions on other controllers use **`require_admin`** for destructive/import/export operations.

Allowlist logic: `Admin.allowed_email?` reads **`ALLOWED_ADMIN_EMAILS`** via `ENV.fetch` and supports legacy **`users`** rows on cutover DBs (see `app/models/admin.rb`).

---

## Environment variables

| Variable | Purpose |
|----------|---------|
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | OAuth (also accepted: `GOOGLE_OAUTH_CLIENT_ID` / `GOOGLE_OAUTH_CLIENT_SECRET`) |
| `ALLOWED_ADMIN_EMAILS` | Comma/semicolon/newline-separated emails allowed to complete staff sign-in |
| `DATABASE_URL` | Production Postgres URL (Heroku) |
| `DATABASE_HOST`, `DATABASE_USER`, `DATABASE_PASSWORD` | Override local `config/database.yml` defaults |
| `SECRET_KEY_BASE` | Required in production |
| `RAILS_LOG_LEVEL`, `ASSUME_SSL`, `FORCE_SSL` | Optional production tuning |
| `SOLID_QUEUE_IN_PUMA` | If set, Solid Queue can run inside Puma (single-dyno mode) |
| `SEED_SAMPLE_DATA` | If `true` in production, seeds may add demo attendees (normally off) |

Local development: copy **`.env.example`** to **`.env`** (`dotenv-rails` loads it in development/test).

---

## Domain model (tables)

Core tables include: **`admins`**, **`ideathon_years`**, **`registered_attendees`**, **`teams`**, **`ideathon_events`**, **`sponsors_partners`**, **`mentors_judges`**, **`faqs`**, **`rules`**, **`activity_logs`**, **`manager_action_logs`**.

`Ideathon` is an alias model for the same table as **`IdeathonYear`** (shared concern `IdeathonYearShared`).

Migrations include **Heroku / legacy cutover** paths (guarded `create_table`, `users` → `admins`, log FK migration). See `db/migrate/` and root **`README.md`** (Replacing 501-club-staging).

---

## Background jobs and release phase

- **Heroku `Procfile`:** `release` runs `db:migrate` then **`db:seed`** (same pattern as the older staging app).
- **`worker`:** `bundle exec bin/jobs start` (Solid Queue).
- **Production seeds** are idempotent; demo attendee seeding is skipped in production unless **`SEED_SAMPLE_DATA=true`**.

---

## Testing and CI

```bash
bundle install
bash script/start-db   # or your own Postgres
export DATABASE_HOST=127.0.0.1   # optional on Windows if ::1 causes issues
bundle exec rails db:prepare
bundle exec rspec
```

- **RSpec** is the primary test stack (including **`spec/system`** for browser tests — run with `bundle exec rspec spec/system`).
- **SimpleCov** enforces a minimum line coverage (see `spec/spec_helper.rb`).
- **GitHub Actions** (`.github/workflows/ci.yml`): Brakeman, importmap audit, RuboCop, `db:test:prepare`, RSpec on **push/PR to `main`**.

Other useful commands: `bundle exec rubocop`, `bundle exec brakeman -q`.

---

## Deployment (Heroku)

See the root **`README.md`** section **Deploying to Heroku** and **Replacing 501-club-staging with this repo** for:

- Required addons and config vars
- `web` + `worker` scaling
- Release command and seed behavior
- Active Storage on `:local` (ephemeral on Heroku) — use object storage for durable uploads if needed

---

## In-app documentation delivery

Organizer nav links point at **`/UserDocumentation.pdf`** and **`/TechnicalDocumentation.pdf`**. Rails serves them as **`application/pdf`** from **`public/UserDocumentation.pdf`** and **`public/TechnicalDocumentation.pdf`** (no custom routes). Update the PDFs in **`public/`** when you ship revised guides; keep **`docs/*.md`** in sync if you maintain Markdown sources.

---

## Further reading

- **`README.md`** — local setup, Windows notes, Heroku, troubleshooting.
- **`MERGE_ADMIN_DASHBOARD_NOTES.md`** — short history of the dashboard merge and follow-ups.
