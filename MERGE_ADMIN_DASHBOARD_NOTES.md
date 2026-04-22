# Admin dashboard merge — notes

This file records the **intent and outcome** of merging organizer dashboard features into the **501-plan** codebase (the TAMU Ideathon web app). It is **not** a day-to-day runbook; use **`README.md`** and **`docs/technical_documentation.md`** for current setup and deployment.

## What was integrated

- **`/dashboard`** routes for ideathon years (as **Ideathons**), sponsors/partners, mentors/judges, FAQs, rules, activity logs, and admin user management.
- **`Admin`** roles (`admin`, `editor`, `unauthorized`) and controller-level restrictions (`require_admin` on destructive/import/export paths where required).
- Shared **`Ideathon` / `IdeathonYear`** model layer for dashboard and public routes.
- CSV import helpers and activity tracking for dashboard models.

## Heroku / legacy database cutover

Later work added **idempotent migrations** and optional **`users` → `admins`** / log FK migration paths so a GitHub repo that previously deployed **501-club-staging** can be replaced with this tree without recreating Postgres. Details: **`README.md`** section *Replacing `501-club-staging` with this repo*.

## Validation

The application is expected to pass **`bundle exec rspec`** with PostgreSQL available (see CI in `.github/workflows/ci.yml`). Local prerequisites: Ruby **3.4.6**, Bundler, Postgres, and optionally **`DATABASE_HOST=127.0.0.1`** on Windows if IPv6 causes connection errors.
