# TAMU Ideathon Web Application

**Project Title:** TAMU Ideathon Web Application
**Description:** This repository contains the source code for the **TAMU Ideathon 2026** web
application – a Ruby on Rails service used to advertise the event, collect
registrations from students, and allow administrators to manage participants,
teams, and ideathon events.

Developer Emails:
- samnguyen02@tamu.edu
- joyceluo04@tamu.edu
- oscarbravo@tamu.edu
- lilly_seeley@tamu.edu

Admin Dashboard Developers:
- williamt2023@tamu.edu
- raafay.ah@tamu.edu
- Ernestbarren01@yahoo.com
- zzh021015@tamu.edu


## Table of Contents
- [Project Title & Description](#tamu-ideathon-web-application)
- [Requirements (Internal & External Components)](#requirements-internal--external-components)
- [External Dependencies](#external-dependencies)
- [Environmental Variables/Files](#environmental-variablesfiles)
- [Installation and Setup](#installation-and-setup)
- [Usage](#usage)
- [Features](#features)
- [Documentation](#documentation)
- [Local DB Helper Scripts](#local-db-helper-scripts-git-bash--wsl-bash)
- [Deployment](#deployment)
- [Useful Commands](#useful-commands)
- [Continuous Integration](#continuous-integration)
- [Credits and Acknowledgements](#credits-and-acknowledgements)
- [Third Party Libraries](#third-party-libraries)
- [Contact Information](#contact-information)
- [Contribution](#contribution)
- [License](#license)

## Features

* Public-facing landing page with event details, schedule, rules, and FAQs.
* Public registration for attendees (web form; **@tamu.edu** email validation).
* Staff sign-in and dashboards (**Devise** + **Google OAuth2** for `Admin` users) to manage registrations, teams, exports, and content.
* Static asset pipeline powered by TailwindCSS and importmap.
* Basic health check endpoint (`/up`) for deployment monitoring.

The default browser **title** in `app/views/layouts/application.html.erb` may still say **“501 Club - Ideathon Manager”**; the product is the **TAMU Ideathon** site and organizer tools described here.

## Requirements (Internal & External Components)

**Internal Components:**
*   **Ruby on Rails**: Core web framework.
*   **ActiveRecord**: ORM mapping.
*   **Solid Queue / Solid Cache / Solid Cable**: Backend caching, background jobs, and WebSocket handling.
*   **Tailwind CSS & Importmap**: Asset pipeline styling and JS modules.

**External Components:**
*   **PostgreSQL**: Relational database managing event data, attendees, etc.
*   **Google OAuth2**: External authentication provider for staff login.
*   **Heroku (Optional)**: Assumed platform-as-a-service for deployment.

## External Dependencies

*   **Ruby 3.4.6**: The primary programming language.
*   **PostgreSQL**: External database server.
*   **Node.js**: Recommended for local Tailwind CSS watching.
*   **Google APIs**: Required for staff SSO (configured via `.env`).
*   **Chrome / ChromeDriver**: External dependencies utilized by Capybara for system testing.
*   *For a complete list of programmatic dependencies, see the [Third Party Libraries](#third-party-libraries) section or the Gemfile.*

## Environmental Variables/Files

The core environment setup resides in `.env`. Copy the example environment file and fill in required values:

```sh
cp .env.example .env
# edit .env and set Google OAuth values and ALLOWED_ADMIN_EMAILS as needed
```

Google OAuth env compatibility:
- `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` (same naming as `501-club-staging`)
- `GOOGLE_OAUTH_CLIENT_ID` / `GOOGLE_OAUTH_CLIENT_SECRET` (also supported)

Database connection values are read from `config/database.yml` and can be
overridden with:
- `DATABASE_HOST`
- `DATABASE_USER`
- `DATABASE_PASSWORD`

You may also use Rails credentials for sensitive values; see `config/credentials.yml.enc`.

## Installation and Setup

These instructions will help you set up a copy of the project on your local
development machine for development and testing purposes.

### Prerequisites

* **Ruby 3.4.6** (matches `.ruby-version`; managed via rbenv, rvm, or your system package manager).
* **Bundler** (`gem install bundler`).
* **PostgreSQL** server running locally (default config expects `localhost:5432`,
  user `postgres`, password `postgres` unless you override env vars).
* **Node.js** (recommended for Tailwind watcher support in local dev workflows).
* **Bash shell** for helper scripts under `script/` (Git Bash/WSL on Windows).

> Ruby dependencies are defined in `Gemfile`.

### First-Time Setup (after clone)

Start PostgreSQL first, then run setup:

```sh
bash script/start-db
ruby bin/setup --skip-server
```

`bin/setup` is idempotent and will:
- verify/install gems
- run `db:prepare`
- clear logs/tmp files

Then start development services:

```sh
bin/dev
```

Open `http://localhost:3000`.

For Windows (Git Bash/WSL), use:

```sh
bash script/start-db
ruby bin/setup --skip-server
TAILWIND_WATCH=0 bash script/app-start
```

If `bash` is not on your PATH, run the same scripts with Git Bash explicitly, for example  
`"C:\Program Files\Git\bin\bash.exe" script/start-db`.

If Rails then fails to connect to Postgres with errors mentioning `::1` / IPv6, set `DATABASE_HOST=127.0.0.1` for your shell session (or add it to `.env`) so the app uses IPv4.

If `bin/setup` fails with `ActiveRecord::ConnectionNotEstablished` or
`PG::ConnectionBad` and mentions `localhost:5432 refused`, PostgreSQL is not
running yet. Run `bash script/start-db` (or start your local Postgres service),
then run `ruby bin/setup --skip-server` again.

### Database Setup

Prepare (create + migrate) the database:

```sh
bundle exec rails db:prepare
```

Optionally seed initial data:

```sh
bundle exec rails db:seed
```

### Installing Dependencies

```sh
bundle install
```

### Running the Server

Use the standard Rails dev server:

```sh
bundle exec rails server
```

Browse to `http://localhost:3000` to view the landing page.

## Usage

**How to use the local development setup:**
1. Ensure the PostgreSQL database is running (`bash script/start-db`).
2. Start the Rails server using `bin/dev` or `bundle exec rails s`.
3. Open `http://localhost:3000` to access the public Ideathon Web App.
4. For administration usage, log in at `/admins/sign_in` using the configured Google OAuth provider. Authorized users (those mapped in `.env`) can access the dashboard.
5. In the dashboard, Admins can view/edit registrations, update application pages, and configure settings. 

## Documentation

| Audience | Location |
|----------|-----------|
| Organizers (how to use dashboards, roles, publishing) | [`docs/user_documentation.md`](docs/user_documentation.md) |
| Engineers / DevOps (stack, env, CI, deployment) | [`docs/technical_documentation.md`](docs/technical_documentation.md) |
| Architecture map (public vs dashboard vs shared data) | [`docs/admin_dashboard_system_guide.md`](docs/admin_dashboard_system_guide.md) |
| Historical merge context | [`MERGE_ADMIN_DASHBOARD_NOTES.md`](MERGE_ADMIN_DASHBOARD_NOTES.md) |
| Local Postgres helper scripts | [`script/ReadMe.md`](script/ReadMe.md) |

**In the browser (signed-in organizer nav):** **User Guide** and **Technical Documentation** open **`public/UserDocumentation.pdf`** and **`public/TechnicalDocumentation.pdf`** at **`/UserDocumentation.pdf`** and **`/TechnicalDocumentation.pdf`** (static files, same as `501-club-staging`). Markdown copies for editing in-repo remain under **`docs/`** but are not what the nav serves.

### Running Tests

RSpec is used for model/request/system specs. To execute the suite:

```sh
bundle exec rspec
```

SimpleCov is enabled in `spec/spec_helper.rb` and writes output to `coverage/`.
The test run will fail if coverage drops below the configured minimum.

System-style browser specs live under **`spec/system`** (RSpec). Run them with:

```sh
bundle exec rspec spec/system
```

They require **Chrome** and a matching **ChromeDriver** on your PATH (same as typical Capybara + Selenium setups).

### Linting and Formatting

* RuboCop for Ruby (`bundle exec rubocop`).
* Brakeman security scan (`bundle exec brakeman -q`).
* Tailwind classes are auto-purged during asset compilation.

## Local DB Helper Scripts (Git Bash / WSL bash)

For local development on Windows, helper scripts are available in `script/`:

```sh
bash script/start-db
bash script/stop-db
bash script/app-start
```

`script/app-start` will:
- start local PostgreSQL
- ensure gems are installed
- run `bin/rails db:prepare`
- start Rails on `http://localhost:3000`
- start Tailwind watcher unless `TAILWIND_WATCH=0`

Example:

```sh
TAILWIND_WATCH=0 bash script/app-start
```

## Deployment

`501-plan` can be deployed to Heroku and other Rack-compatible hosts.
A `Dockerfile`, `Procfile.dev`, and production `Procfile` are included.

### Deploying to Heroku

`501-plan` runs on Heroku with two process types:
- `web` (`bundle exec puma -C config/puma.rb`)
- `worker` (`bundle exec bin/jobs start`)

1. **Create and connect your Heroku app:**
   ```sh
   heroku create your-app-name
   heroku git:remote -a your-app-name
   ```
2. **Provision Postgres and set required config vars:**
   ```sh
   heroku addons:create heroku-postgresql:hobby-dev
   heroku config:set SECRET_KEY_BASE=... GOOGLE_CLIENT_ID=... GOOGLE_CLIENT_SECRET=...
   ```
   Optional:
   ```sh
   heroku config:set ALLOWED_ADMIN_EMAILS=you@tamu.edu,other@tamu.edu
   heroku config:set ASSUME_SSL=true FORCE_SSL=true RAILS_LOG_LEVEL=info
   ```
   Notes:
   - Heroku sets `DATABASE_URL` automatically after provisioning Heroku Postgres.
   - You may set `GOOGLE_OAUTH_CLIENT_ID`/`GOOGLE_OAUTH_CLIENT_SECRET` instead of `GOOGLE_CLIENT_ID`/`GOOGLE_CLIENT_SECRET`.
   - If `ALLOWED_ADMIN_EMAILS` is unset, sign-in falls back to legacy `users` with `role` in (`admin`,`editor`) for `@tamu.edu` only (cutover from `501-club-staging`). Prefer setting the env var explicitly in production.
3. **Deploy your code:**
   ```sh
   git push heroku main
   ```
4. **Scale required dynos:**
   ```sh
   heroku ps:scale web=1 worker=1
   ```
5. **Open your app:**
   ```sh
   heroku open
   ```

Release phase (matches `501-club-staging`): migrations then seeds on every deploy.

```Procfile
release: DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:migrate && bundle exec rails db:seed
```

Production seeds are idempotent and do not inject demo attendees unless `SEED_SAMPLE_DATA=true`.
When creating Ideathon 2026 for the first time, seeds clear any other `is_active` years first so databases that still carry the staging-era “single active year” unique index cannot fail deploy.

### Replacing `501-club-staging` with this repo

When you overwrite the GitHub repo that Heroku deploys from (previously `501-club-staging`) with `501-plan`:

1. **Backup first:** `heroku pg:backups:capture -a your-app-name`
2. **Confirm dynos:** `heroku ps:scale web=1 worker=1 -a your-app-name`
3. **Push / auto-deploy** as usual; release runs `db:migrate` then `db:seed`.
4. **Verify:** `heroku logs --tail`, open `/up`, sign in as admin, smoke-test registration and dashboard.
5. **Rollback:** `heroku releases:rollback` if release phase fails; restore DB from backup if needed.

Migrations are written so an existing staging Postgres (with `users`, `ideathon_years`, etc.) continues to work: legacy rows are copied into `admins` and log foreign keys are migrated from `user_id` to `admin_id` where applicable.

### Storage note for Heroku

Production currently uses `config.active_storage.service = :local`.
Heroku dyno filesystems are ephemeral, so uploaded files are not durable across
restarts/deploys. Use S3 or another persistent object store for production uploads.

### Optional single-dyno queue mode

For low-traffic deployments, you can run queue supervision in Puma:

```sh
heroku config:set SOLID_QUEUE_IN_PUMA=1
heroku ps:scale web=1 worker=0
```

Use a dedicated `worker` dyno again when background load increases.

For more details, see [Heroku Dev Center](https://devcenter.heroku.com/categories/ruby-support).

### Health and Monitoring

The `/up` endpoint returns `200` when the app boots successfully. Use this in
load balancer health checks or uptime monitors.

## Useful Commands

* `rails console` – open interactive session
* `rails db:reset` – drop, recreate, migrate, and seed the database
* `rails routes | grep ideathon` – view route list
* `heroku ps` – verify web/worker process state
* `heroku logs --tail` – stream production logs

## Continuous integration

GitHub Actions (`.github/workflows/ci.yml`) runs on **push** and **pull_request** to **`main`**: Brakeman, importmap audit, RuboCop, `db:test:prepare`, and the full **RSpec** suite. Keep CI green before merging.

## Credits and Acknowledgements

*   **GitHub Copilot**: AI autocomplete was used to assist with code generation and standardizing logic patterns within the product.
*   **Large Language Models (LLMs)**: AI reasoning assisted in small parts for troubleshooting environment configuration and structural documentation formatting.
*   **TAMU Contributors**: See Contact Information and commit history for student and organizer collaboration.

## Third Party Libraries

*(Includes AI resources and open-source frameworks)*

- **GitHub Copilot**: Machine-learning auto-complete.
- rails
- propshaft
- pg
- puma
- importmap-rails
- turbo-rails
- stimulus-rails
- jbuilder
- tailwindcss-rails
- dotenv-rails
- devise
- omniauth
- omniauth-rails_csrf_protection
- omniauth-google-oauth2
- tzinfo-data
- solid_cache
- solid_queue
- solid_cable
- csv
- bootsnap
- kamal
- thruster
- debug
- brakeman
- rubocop-rails-omakase
- web-console
- capybara
- selenium-webdriver
- minitest
- rspec-rails
- shoulda-matchers
- simplecov
- rubocop

## Contact Information

Team Members:

Will Tschirhart - williamt2023@tamu.edu

Raafay Hemani   - raafay.ah@tamu.edu

Ernest Barron   - Ernestbarren01@yahoo.com

Zihao Zhu       - zzh021015@tamu.edu

## Contribution

Fork the repository, create a feature branch, and open a Pull Request. Run
`bundle exec rspec` locally to ensure tests pass. Code style follows
[Rails defaults](https://guides.rubyonrails.org/).

## License

This project is licensed under the MIT License – see `LICENSE` for details.


---
Documentation in this file was last reviewed for accuracy in **April 2026**.
