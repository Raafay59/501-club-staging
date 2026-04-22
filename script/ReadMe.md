# `script/` — local development helpers

Everything in this directory is for **local development only** (not used by Heroku release).

All scripts are **Bash**. On Windows, run them with **Git Bash** or WSL, for example:

```text
"C:\Program Files\Git\bin\bash.exe" script/start-db
```

## Scripts

| Script | Purpose |
|--------|---------|
| **`start-db`** | Ensures a local PostgreSQL data directory exists, initializes it if needed, starts the server (default port **5432**), waits until ready. Override **`PG_BIN`**, **`PG_DATA`**, **`PG_PORT`** if your install paths differ. |
| **`stop-db`** | Stops the cluster started by `start-db`. |
| **`app-start`** | Starts Postgres (via `start-db`), installs gems if needed, runs **`bin/rails db:prepare`**, starts Rails on port 3000, and by default runs the Tailwind watcher. Set **`TAILWIND_WATCH=0`** to skip the watcher. |

Typical flow after cloning:

```bash
bash script/start-db
ruby bin/setup --skip-server
bin/dev
```

If Rails cannot connect and errors mention **`::1`**, set **`DATABASE_HOST=127.0.0.1`** for your shell or add it to **`.env`** (see root **`README.md`**).
