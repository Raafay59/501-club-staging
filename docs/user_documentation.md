# TAMU Ideathon User Documentation

This guide is for **organizers** who use the **Event manager** (registration), **Ideathon events**, and **dashboard** tools to run the ideathon. Students use the **public** site to read details and register; they do not need a staff account.

## How in-app help works

From the organizer navigation bar you can open:

- **User Guide** — PDF at **`/UserDocumentation.pdf`** (file: **`public/UserDocumentation.pdf`**). This Markdown file is an editable copy in the repo; replace the PDF when the guide changes.
- **Technical Documentation** — PDF at **`/TechnicalDocumentation.pdf`** (file: **`public/TechnicalDocumentation.pdf`**), same pattern.

---

## Signing in

1. Go to **`/admins/sign_in`** (or use **Sign in** from the public site when offered).
2. Choose **Sign in with Google** and use your **@tamu.edu** Google account.

### Who can sign in as staff?

- Your email must be allowed. Normally an **admin** sets **`ALLOWED_ADMIN_EMAILS`** on the server (comma / semicolon / newline separated list).
- If that list is **empty** on a database that was migrated from the older **501-club-staging** app, sign-in may still be allowed for **@tamu.edu** addresses that exist in the legacy **`users`** table with role **`admin`** or **`editor`** (cutover compatibility only). Prefer configuring **`ALLOWED_ADMIN_EMAILS`** in production.

If you can sign in but see “not authorized for organizer tools”, your `Admin` record may have role **`unauthorized`**. Ask a full **admin** to fix your role or add your email to the allowlist.

---

## Roles: **admin** vs **editor**

Both **admin** and **editor** can use the Event manager and most dashboard content.

**Only admins** can:

- Open **Manage Users** (`/dashboard/users`) — create/update/remove staff accounts
- **Delete** records and run **CSV import** in several dashboard modules (sponsors/partners, mentors/judges, FAQs, rules, ideathons), and **export** where restricted

Editors can create and edit most content but may be blocked from destructive or bulk actions above. If a button is missing or you get “Only admins can perform this action”, ask an admin.

---

## Public site (everyone)

- **Home:** `/` — schedule, FAQs, rules, sponsors, mentors, etc., for the **active** ideathon year (see Ideathons dashboard).
- **Register:** `/registered_attendees/new` — team selection and attendee details (TAMU email rules apply).

No Google staff sign-in is required for the public registration flow.

---

## Event manager (registration)

**Path:** `/manager`

Use this area to:

- Browse **registered attendees** and **teams** for the active content year
- **Search** by attendee name or team
- **Export** participants or teams as CSV
- **Remove** an attendee (with logging)
- See **recent organizer actions** in the log list

Registration data is stored per **ideathon year** and **team**.

---

## Ideathon events (schedule on the public site)

**Paths:** `/ideathon_events/new`, `/ideathon_events/:id/edit`, etc.

Create and edit **dated events** (check-in, ceremonies, workshops, etc.) tied to the active year. These feed the public schedule.

---

## Dashboard (content & settings)

All paths are under **`/dashboard/...`** and require an authorized staff sign-in.

| Area | Path (relative) | Purpose |
|------|-----------------|--------|
| Ideathons | `/dashboard/ideathons` | Years, active flag, overview, CSV import (admin), delete year (admin) |
| Sponsors & Partners | `/dashboard/sponsors_partners` | Logos, blurbs, import/export (admin for import/export) |
| Mentors & Judges | `/dashboard/mentors_judges` | Bios, photos, import/export (admin for import/export) |
| FAQs | `/dashboard/faqs` | Questions/answers; import (admin); delete (admin) |
| Rules | `/dashboard/rules` | Rule text; import (admin); delete (admin) |
| Activity log | `/dashboard/activity_logs` | Filterable audit of dashboard content changes |
| Manage users | `/dashboard/users` | **Admins only** — staff emails and roles |

Use **Ideathons** to set which year is **active** on the public site (only one should be active at a time).

---

## Publishing workflow

1. In **Ideathons**, ensure the correct year exists and is marked **active** for the public site.
2. Add or update **sponsors**, **mentors/judges**, **FAQs**, and **rules** for that year.
3. Add **events** under **Ideathon events** if the schedule should change.
4. Open the **public home page** (`/`) in a private window or another browser to confirm content and registration.

---

## Exports and imports

- **Manager** exports (participants / teams) are CSV downloads from `/manager`.
- Dashboard **import** and some **export** actions are **admin-only** where noted above. Use the provided CSV templates and headers expected by each importer (errors usually name the missing column).

---

## Health check (for organizers coordinating with IT)

The app exposes **`/up`** for load balancers. It should return **200** when the app is healthy.

---

## Troubleshooting

| Problem | What to check |
|--------|----------------|
| Cannot sign in with Google | `@tamu.edu` account, `ALLOWED_ADMIN_EMAILS`, or legacy `users` role (see above). |
| “Not authorized” after sign-in | Role is `unauthorized`; ask an admin to update **`Admin`** in **Manage Users**. |
| Public site shows wrong year | **Ideathons** — exactly one year should be **active**. |
| Export is empty | Records exist for the **active** year; filters or year selection in the UI. |
| Import fails | File is CSV; required headers; you are an **admin** if the action is admin-only. |
| Heroku “documentation” link in manager | Uses `public/heroku_documentation.pdf` if present; otherwise you see an alert. |

---

## Sign out

Use **Sign Out** in the organizer navigation. If something looks stuck, sign out again or clear site cookies for this host.
