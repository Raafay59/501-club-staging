# README

Technical documentation: https://docs.google.com/document/d/1xxk5U2dwN3DLhmVX_49dyWp3lmFKhvyWa4AkdA4sRR8/edit?usp=sharing
User documentation: https://docs.google.com/document/d/1ZCRiQinY-WYUEtjqU2NyGJmNdjY22iqxtoXGiZmghqQ/edit?usp=sharing

## 501 Club Staging - Local Setup

This is a Rails 8 app using PostgreSQL.

## Prerequisites

- Ruby `3.4.6` (from `.ruby-version`)
- Bundler
- PostgreSQL available on `localhost:5432`

## 1. Install gems

```bash
bundle install
```

## 2. Database setup

Run the standard Rails setup:

```bash
bin/rails db:prepare
```

If PostgreSQL is not already running as a system service, start a local cluster.

### Example: local PostgreSQL cluster (Git Bash on Windows)

```bash
# One-time initialization (use a UTF8 cluster)
initdb -D /c/Users/<your-user>/pgsql/devdata_utf8 -U postgres -A trust --encoding=UTF8 --locale=C

# Start PostgreSQL (keep this terminal open)
postgres -D /c/Users/<your-user>/pgsql/devdata_utf8 -p 5432
```

If needed, create a local role/database matching your Windows username:

```bash
createuser -h localhost -p 5432 -U postgres -s <your-user>
createdb -h localhost -p 5432 -U postgres <your-user>
```

## 3. Start the app

```bash
bin/dev
```

or

```bash
bin/rails server
```

### One-command local start (DB + app + browser)

```bash
bash script/app-start
```

To skip the Tailwind watcher when you do not want the extra process:

```bash
TAILWIND_WATCH=0 bash script/app-start
```

This command will:
- start local PostgreSQL (via `script/start-db`)
- ensure gems are installed
- run `bin/rails db:prepare`
- start Rails on `http://localhost:3000`
- start Tailwind watcher (`bin/rails tailwindcss:watch`) for live CSS updates, unless `TAILWIND_WATCH=0` is set
- open your default browser automatically

Note: The public Ideathon site and organizer/admin dashboard are served by the same Rails app.
Starting this script boots both surfaces together.

For a full system map of the admin dashboard, public-site integration, codebase layout, and database structure, see [docs/admin_dashboard_system_guide.md](docs/admin_dashboard_system_guide.md).

### Background jobs for notifications

- In `development`, Active Job uses `:async`, so jobs run in-process while the Rails server is running.
- In `production`, Active Job uses `:solid_queue`, so a worker process must be running to process `deliver_later` emails.

Run a worker manually with:

```bash
bundle exec bin/jobs start
```

If you deploy with `Procfile` process types, run both `web` and `worker`.
Alternatively, for single-process deployments, you may set `SOLID_QUEUE_IN_PUMA=1` to run the Solid Queue supervisor inside Puma.

### Local email preview in development

Development mail delivery previews are opt-in. To enable them:

```bash
ENABLE_LOCAL_EMAIL_DELIVERY=true bin/rails server
```

## 4. Smoke test

```bash
bin/rails runner "puts 'BOOT_OK'"
```

If this prints `BOOT_OK`, Rails booted successfully with DB connectivity.

## Quick DB scripts (Git Bash)

Start Postgres with one command (auto-initializes a UTF8 cluster if needed):

```bash
bash script/start-db
```

Stop Postgres with one command:

```bash
bash script/stop-db
```

Optional overrides if your paths differ:

```bash
PG_BIN=/c/Users/<your-user>/pgsql/pgsql/bin PG_DATA=/c/Users/<your-user>/pgsql/devdata_utf8 bash script/start-db
```

## Helpful commands

```bash
bin/rails db:migrate
bin/rails db:seed
bin/rails db:reset
bundle exec rspec
```
