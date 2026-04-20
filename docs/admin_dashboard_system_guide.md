# 501 Club Admin Dashboard System Guide

This guide is the single source of truth for how the 501 Club organizer/admin experience works in this Rails app and how it connects to the public Ideathon site.

It is written for someone opening the codebase for the first time and needing a complete mental model of:

- what the admin/dashboard area can do,
- how organizers reach it from the public site,
- how roles and authorization work,
- where each feature lives in the codebase,
- and how the database supports the whole system.

## 1. High-Level System View

The application is split into two closely related surfaces that share the same data:

- The public Ideathon website, served by [app/controllers/ideathon_controller.rb](../app/controllers/ideathon_controller.rb) and rendered through [app/views/ideathon/index.html.erb](../app/views/ideathon/index.html.erb).
- The organizer/admin area, which includes the manager dashboard plus CRUD pages for the content that feeds the public site.

The public site is the front-facing marketing and registration experience. The admin/dashboard side is where organizers maintain the content that appears publicly: events, teams, registration data, sponsors, partners, mentors, judges, FAQs, rules, ideathon years, and user access.

At a practical level, the public site and dashboard are not separate applications. They are different routes and controllers inside the same Rails project, sharing the same models, database, authentication state, and helper methods.

## 2. Access Control and Roles

### User roles

Roles are defined in [app/models/user.rb](../app/models/user.rb):

- `admin`
- `editor`
- `unauthorized`

The `authorized?` predicate returns true for admins and editors. That is the main line between people who can use organizer tools and people who cannot.

### Login flow

The sign-in flow is handled in [app/controllers/sessions_controller.rb](../app/controllers/sessions_controller.rb). It uses OmniAuth Google callback data to find or create a `User` record, then stores the user ID in the session.

Behavior to know:

- If the user already exists by `uid` and provider, that record is reused.
- If the user only matches by email, the app attaches the provider/uid data to the existing email record.
- Otherwise, a new user is created with role `unauthorized`.
- Authorized users are sent into the dashboard area.
- Unauthorized users are sent to the pending-approval page.

The pending-approval page is [app/views/sessions/unauthorized.html.erb](../app/views/sessions/unauthorized.html.erb).

### Authorization rules

The two most important enforcement layers are:

- [app/controllers/application_controller.rb](../app/controllers/application_controller.rb), which blocks public manager tools unless the user is signed in with an authorized role.
- [app/controllers/club_dashboard_controller.rb](../app/controllers/club_dashboard_controller.rb), which is the base class for the dashboard CRUD controllers and requires login plus authorization.

Important distinctions:

- Admins and editors can use the dashboard area.
- Admins can do everything editors can do, plus user management and some destructive/import/export actions.
- Unauthorized users are redirected away from dashboard pages.
- Public registration pages are deliberately exempted so visitors can register without logging in.

## 3. Public Site Entry Points Into Admin Tools

There are two main ways a user reaches the admin/dashboard area from the public site:

1. The desktop and mobile hero/navigation CTA on the Ideathon homepage.
2. The shared organizer navigation that appears once a user is signed in and authorized.

### Homepage CTA behavior

In [app/views/ideathon/index.html.erb](../app/views/ideathon/index.html.erb), the main call-to-action changes based on `organizer_tools?`:

- Authorized organizers see a direct `Dashboard` link to `manager_index_path`.
- Everyone else sees a `Sign in` link to `login_path`.

The mobile nav uses the same pattern, so the public site is the primary on-ramp to organizer tools.

### Shared organizer navigation

[app/views/layouts/application.html.erb](../app/views/layouts/application.html.erb) shows a top nav when a user is signed in and authorized.

That nav links to:

- Public Ideathon site
- Event manager (registration)
- Ideathons
- Sponsors & Partners
- Mentors & Judges
- FAQs
- Rules
- Activity Log
- Manage Users, but only for admins

This makes the dashboard feel like one workspace instead of a collection of unrelated pages.

## 4. Route Map

The relevant routes are defined in [config/routes.rb](../config/routes.rb).

### Public and session routes

- `/` -> public Ideathon homepage
- `/login` -> sign-in page
- `/auth/:provider/callback` -> OmniAuth callback
- `/auth/failure` -> auth failure handling
- `/logout` -> sign out
- `/unauthorized` -> pending approval page

### Manager dashboard routes

- `/manager` -> dashboard overview
- `/manager/:id` -> delete attendee
- `/manager/export_participants` -> attendee CSV export
- `/manager/export_teams` -> team CSV export
- `/manager/view_pdf` -> inline Heroku documentation PDF

### Dashboard content routes under `/dashboard`

- `users` -> user administration
- `activity_logs` -> audit log viewer
- `ideathons` -> year management and overview pages
- `sponsors_partners` -> sponsor/partner content management
- `mentors_judges` -> mentor/judge content management
- `faqs` -> FAQ management
- `rules` -> rule management

### Registration and event routes

- `registered_attendees` -> attendee registration and attendee management
- `ideathon_events` -> event management for the active year

Those routes are important because the dashboard is not only a reporting screen. It is also the operational control surface for the public registration and content system.

## 5. Manager Dashboard Feature Set

The main dashboard lives in [app/controllers/manager_controller.rb](../app/controllers/manager_controller.rb) and [app/views/manager/index.html.erb](../app/views/manager/index.html.erb).

It is the organizer’s high-level operations page, with three main tabs: attendees, events, and activity.

### 5.1 Attendees tab

This is the most operationally important part of the dashboard.

What it does:

- Shows registered attendees for the active ideathon year.
- Supports search by attendee name or team name.
- Supports sorting by team or by name.
- Lets authorized users add a new attendee.
- Lets admins delete attendees.
- Shows the attendee count and the number of teams for the active year.

Implementation details:

- Data is scoped to the active year through [app/services/active_ideathon_year.rb](../app/services/active_ideathon_year.rb).
- Search comes from `RegisteredAttendee.search_by_name_or_team` in [app/models/registered_attendee.rb](../app/models/registered_attendee.rb).
- Team sorting comes from `RegisteredAttendee.sorted_by_team`.
- Search input is debounced by [app/javascript/controllers/manager_search_controller.js](../app/javascript/controllers/manager_search_controller.js).
- Tab state is preserved by [app/javascript/controllers/manager_tabs_controller.js](../app/javascript/controllers/manager_tabs_controller.js), including URL-driven tab selection.

How the manager page behaves:

- Search updates without a full page interaction delay.
- Turbo is used where possible for smoother updates.
- Deleting an attendee can respond with either HTML or Turbo Stream.
- The action log panel is updated after destructive attendee actions.

### 5.2 Events tab

This shows `IdeathonEvent` records for the active year.

What it does:

- Lists events sorted by date and time.
- Lets organizers create, edit, and delete events.
- Records event actions into the manager action log.

Implementation details:

- The controller is [app/controllers/ideathon_events_controller.rb](../app/controllers/ideathon_events_controller.rb).
- The active year is attached automatically when creating a new event.
- Event updates capture changed fields so the log can show a meaningful change summary.
- Destroy actions update the action log via Turbo Stream when requested.

### 5.3 Activity tab

This displays recent manager actions across all organizers.

What it does:

- Shows the latest 200 manager actions.
- Displays who performed each action.
- Shows the action label, target, record label, and change summary.
- Refreshes when attendee/event actions occur.

Implementation details:

- The dashboard uses [app/models/manager_action_log.rb](../app/models/manager_action_log.rb).
- Logging is performed through [app/controllers/concerns/manager_action_logging.rb](../app/controllers/concerns/manager_action_logging.rb).
- The log is deliberately oriented around human-readable labels instead of raw database fields.

### 5.4 CSV exports

The manager dashboard offers two exports:

- Export Participants CSV
- Export Teams CSV

What they contain:

- Participants export includes name, email, phone, major, class, team, and year.
- Teams export groups attendees by team and lists each member.

These exports only cover the active year and are logged as manager actions.

### 5.5 Heroku documentation PDF

The manager dashboard can open `public/heroku_documentation.pdf` inline.

This is a convenience link rather than a data feature, but it is part of the operational dashboard surface.

### 5.6 Developer contacts and help modal

The manager dashboard includes built-in guidance:

- A developer contacts modal with names, phone numbers, and support areas.
- A help modal describing basic dashboard usage.

These are UI aids, not database-backed features, but they are part of the dashboard experience.

## 6. Dashboard Content Modules

The dashboard area under `/dashboard` contains CRUD and content-management pages that feed the public site.

### 6.1 Ideathons

Controller: [app/controllers/ideathons_controller.rb](../app/controllers/ideathons_controller.rb)

Model: [app/models/ideathon.rb](../app/models/ideathon.rb)

What it provides:

- List all ideathon years.
- Create a new ideathon year.
- Edit the year theme.
- Delete an ideathon year, admin-only.
- Import ideathon years from CSV, admin-only.
- View an overview page that aggregates public-facing content for a specific year.

Why it matters:

- The ideathon year is the parent record for most public content.
- Sponsors, mentors, judges, FAQs, rules, teams, attendees, and events all hang off this year.

The overview page in [app/views/ideathons/overview.html.erb](../app/views/ideathons/overview.html.erb) shows the public-facing data associated with the year.

### 6.2 Sponsors & Partners

Controller: [app/controllers/sponsors_partners_controller.rb](../app/controllers/sponsors_partners_controller.rb)

Model: [app/models/sponsors_partner.rb](../app/models/sponsors_partner.rb)

What it provides:

- Create, view, edit, and delete sponsor/partner entries.
- Import sponsor/partner records from CSV.
- Export sponsor records to CSV.
- Filter by `is_sponsor` and use `job_title` as a display/tiering hint.

Public-site connection:

- These records populate the sponsors area on the public homepage.
- The homepage groups them into presenting, gold, and other sponsor tiers based on `job_title` text.
- Community partners are also shown when sponsor records are explicitly marked as non-sponsors.

### 6.3 Mentors & Judges

Controller: [app/controllers/mentors_judges_controller.rb](../app/controllers/mentors_judges_controller.rb)

Model: [app/models/mentors_judge.rb](../app/models/mentors_judge.rb)

What it provides:

- Create, view, edit, and delete mentor/judge entries.
- Import mentor/judge records from CSV.
- Export judge records to CSV.
- Select year and role through the same model form.

Public-site connection:

- Judges render in the public judges section.
- Mentors render in the public mentors section.
- Photo-bearing mentors/judges also populate the homepage photo area.

### 6.4 FAQs

Controller: [app/controllers/faqs_controller.rb](../app/controllers/faqs_controller.rb)

Model: [app/models/faq.rb](../app/models/faq.rb)

What it provides:

- Create, view, edit, and delete FAQ entries.
- Import FAQs from CSV.

Public-site connection:

- FAQ content is displayed on the public homepage.

### 6.5 Rules

Controller: [app/controllers/rules_controller.rb](../app/controllers/rules_controller.rb)

Model: [app/models/rule.rb](../app/models/rule.rb)

What it provides:

- Create, view, edit, and delete rule text entries.
- Import rules from CSV.

Public-site connection:

- Rules are displayed on the public homepage.

### 6.6 Activity Log

Controller: [app/controllers/activity_logs_controller.rb](../app/controllers/activity_logs_controller.rb)

Model: [app/models/activity_log.rb](../app/models/activity_log.rb)

What it provides:

- A read-only audit trail of content changes.
- Filtering by content type and date range.
- Protection against edits and deletion.
- Automatic email notifications to organizers when logs are created.

This is not the same as the manager action log. It is a broader content audit trail used across the content-management modules.

### 6.7 Manage Users

Controller: [app/controllers/users_controller.rb](../app/controllers/users_controller.rb)

Model: [app/models/user.rb](../app/models/user.rb)

What it provides:

- List users in role order.
- Create a user record by email.
- Update a user’s role.
- Delete a user, with protection against deleting yourself.
- Prevent demoting the last admin.

This is admin-only and is the central place for role governance.

## 7. Public Ideathon Site Behavior

The public homepage is driven by [app/controllers/ideathon_controller.rb](../app/controllers/ideathon_controller.rb).

### Year selection

The controller resolves the displayed year in a specific order:

1. A year explicitly marked `is_active`.
2. The latest year with public content.
3. The latest ideathon year overall.

This matters because the public site should not go blank just because a newer year exists with no published content yet.

### Public content it assembles

The homepage loads:

- the active or fallback ideathon year,
- events for that year,
- sponsors and partners,
- judges and mentors,
- FAQs,
- and rules.

### How admin data appears publicly

The public page is not hand-authored separately. It is rendered directly from the admin-managed tables.

That means:

- updating an ideathon year affects what year the homepage treats as current,
- editing sponsors changes the sponsor blocks on the public site,
- editing judges/mentors changes the public people sections,
- editing FAQs and rules changes the homepage content immediately,
- and managing events changes the schedule shown to visitors.

### Public registration

The registration flow is public and does not require organizer login.

The organizer tools and the public registration flow share the same attendee/team data model. That is why the manager dashboard can show registration data without duplicating it.

## 8. Registration and Event Management

### Registered attendees

The attendee registration flow is handled in [app/controllers/registered_attendees_controller.rb](../app/controllers/registered_attendees_controller.rb) and [app/models/registered_attendee.rb](../app/models/registered_attendee.rb).

Features:

- Public registration form.
- Public success page.
- Public attendee show page.
- Organizer-side attendee edits and deletes.
- Dynamic team lookup for registration forms.

Important behavior:

- A current active year is assigned automatically when creating a new attendee.
- Team choice is not trusted directly from the form; it is resolved by controller logic.
- A team has a maximum size enforced by the selection logic.
- The registration flow can redirect back to the manager dashboard when the attendee is created from there.

### Teams

Teams are modeled in [app/models/team.rb](../app/models/team.rb).

Rules and constraints:

- A team belongs to a single ideathon year.
- Team names are normalized before validation.
- Team names must be unique within a year unless the team is unassigned.
- Only one unassigned team is allowed per year.

The manager dashboard uses teams as the grouping unit for attendee search, exports, and display.

### Events

Events are modeled in [app/models/ideathon_event.rb](../app/models/ideathon_event.rb).

They are the schedule entries for the active year and are managed from the dashboard.

## 9. Logging and Auditing

This app has two separate audit systems, and it is worth keeping them distinct.

### 9.1 ActivityLog

ActivityLog is the broader audit trail for content management.

Key properties:

- Immutable once created.
- Belongs to a user.
- Can be filtered by content type and date range.
- Sends organizer notifications after creation.

The message format is standardized through [app/services/activity_log_message.rb](../app/services/activity_log_message.rb).

### 9.2 ManagerActionLog

ManagerActionLog is the lighter-weight dashboard action trail.

Key properties:

- Captures attendee and event management actions.
- Records user, action, record type/id, metadata, IP, and user agent.
- Powers the activity tab in the manager dashboard.
- Is written through [app/controllers/concerns/manager_action_logging.rb](../app/controllers/concerns/manager_action_logging.rb).

### What gets logged

Examples include:

- attendee.created
- attendee.updated
- attendee.deleted
- event.created
- event.updated
- event.deleted
- export.participants_csv
- export.teams_csv

The dashboard log UI turns these into friendlier labels so organizers can quickly understand what happened.

## 10. Database Layout

The current schema is defined in [db/schema.rb](../db/schema.rb).

### Core identity and access tables

- `users`
- `activity_logs`
- `manager_action_logs`

### Ideathon content tables

- `ideathon_years`
- `ideathon_events`
- `sponsors_partners`
- `mentors_judges`
- `faqs`
- `rules`

### Registration tables

- `teams`
- `registered_attendees`

### Notable schema facts

- `users.email` is unique.
- `users.uid` plus `provider` is unique.
- `ideathon_years.year` is unique.
- Only one active ideathon year is allowed by the partial unique index on `is_active`.
- `teams` has a partial unique index for one unassigned team per year.
- `teams` also has a unique case-insensitive name per year for non-unassigned teams.
- `registered_attendees` belongs to both a team and an ideathon year.
- `activity_logs` and `manager_action_logs` both belong to users.

### How the schema is structured conceptually

`ideathon_years` is the parent table for almost everything the public site shows. The rest of the content tables hang off that year through foreign keys.

That means the year record is the organizing center for:

- schedule events,
- attendees,
- teams,
- sponsors and partners,
- mentors and judges,
- FAQs,
- and rules.

## 11. Migration History That Shapes the Current Design

Two migrations are especially important for understanding why the app looks the way it does now.

### 11.1 ideathons to ideathon_years integration

[db/migrate/20260413120000_integrate_ideathon_years_and_public_site.rb](../db/migrate/20260413120000_integrate_ideathon_years_and_public_site.rb) merged the older year-based ideathon structure into the current `ideathon_years` table and added the public-site support tables.

Why it matters:

- The app used to be more year-centric with the year itself acting like the primary key.
- It now uses a normal Rails-style parent table with a surrogate id and a separate `year` field.
- The public site and dashboard now share a cleaner association model.

### 11.2 Manager logs and admins consolidation

[db/migrate/20260413120001_unify_manager_logs_with_users_and_drop_admins.rb](../db/migrate/20260413120001_unify_manager_logs_with_users_and_drop_admins.rb) moved manager logs from the old `admins` table to `users` and then removed the legacy table.

Why it matters:

- The app now has a unified user model for auth and auditing.
- Manager actions are attributed to the same records that drive login and role checks.

## 12. Codebase Layout

Here is the practical mental map for where functionality lives.

### Controllers

- `app/controllers/ideathon_controller.rb`: public homepage.
- `app/controllers/manager_controller.rb`: attendee/event management dashboard.
- `app/controllers/ideathons_controller.rb`: year CRUD and overview.
- `app/controllers/sponsors_partners_controller.rb`: sponsor/partner content.
- `app/controllers/mentors_judges_controller.rb`: mentors/judges content.
- `app/controllers/faqs_controller.rb`: FAQ content.
- `app/controllers/rules_controller.rb`: rule content.
- `app/controllers/activity_logs_controller.rb`: audit log viewer.
- `app/controllers/users_controller.rb`: user role administration.
- `app/controllers/registered_attendees_controller.rb`: public registration and attendee management.
- `app/controllers/ideathon_events_controller.rb`: schedule events.
- `app/controllers/sessions_controller.rb`: login/logout/approval flow.

### Models

- `app/models/ideathon.rb`: central year model.
- `app/models/team.rb`: team grouping and uniqueness.
- `app/models/registered_attendee.rb`: attendee data and search.
- `app/models/ideathon_event.rb`: schedule entry.
- `app/models/sponsors_partner.rb`: sponsor/partner record.
- `app/models/mentors_judge.rb`: mentor/judge record.
- `app/models/faq.rb`: FAQ record.
- `app/models/rule.rb`: rule record.
- `app/models/activity_log.rb`: immutable content audit.
- `app/models/manager_action_log.rb`: dashboard action audit.
- `app/models/user.rb`: roles and authentication identity.

### Services and concerns

- `app/services/active_ideathon_year.rb`: resolves the year used by organizer tools.
- `app/services/activity_log_message.rb`: formats human-readable audit messages.
- `app/controllers/concerns/manager_action_logging.rb`: writes manager action logs.

### Views

- `app/views/ideathon/index.html.erb`: public site and admin CTA entry point.
- `app/views/manager/index.html.erb`: dashboard UI.
- `app/views/manager/_action_logs.html.erb`: dashboard action log table.
- `app/views/activity_logs/index.html.erb`: audit log filtering page.
- `app/views/layouts/application.html.erb`: shared organizer nav.
- `app/views/layouts/ideathon.html.erb`: visual shell for the public site and several organizer-facing pages.

### JavaScript

- `app/javascript/controllers/manager_tabs_controller.js`: tab state and animation.
- `app/javascript/controllers/manager_search_controller.js`: debounced attendee search.

### Tests

- `spec/requests/manager_spec.rb`: manager dashboard behavior.
- `spec/requests/ideathons_spec.rb`: ideathon CRUD and overview.
- `spec/requests/faqs_spec.rb`: FAQ behavior.
- `spec/requests/activity_logs_spec.rb`: activity log filtering and auth.
- `spec/models/activity_log_spec.rb`: activity log immutability and notifications.
- `spec/models/manager_action_log_spec.rb`: manager log display helpers.
- `spec/controllers/manager_action_logging_spec.rb`: logging concern safety.

## 13. End-to-End Flows

### Flow A: organizer signs in and reaches the dashboard

1. User clicks `Sign in` on the public homepage.
2. OmniAuth returns a Google callback to [app/controllers/sessions_controller.rb](../app/controllers/sessions_controller.rb).
3. The app finds or creates a `User` record.
4. If the user is `admin` or `editor`, they can reach dashboard routes.
5. If the user is `unauthorized`, they are sent to the pending-approval screen.

### Flow B: public content changes appear on the homepage

1. Organizer edits a sponsor, judge, FAQ, rule, event, or ideathon year.
2. The controller saves the record in the admin area.
3. The public homepage controller reloads data from the same tables.
4. The public Ideathon page immediately reflects the updated content the next time it is rendered.

### Flow C: attendee management from the dashboard

1. Organizer searches or sorts attendees in the manager dashboard.
2. Search and sort are scoped to the active year.
3. Adding or editing an attendee updates the registration data.
4. Deleting an attendee removes the record and writes a manager action log entry.

### Flow D: auditing and notification

1. A content record is created, updated, imported, or exported.
2. The model/service produces a human-readable message.
3. An `ActivityLog` or `ManagerActionLog` record is written.
4. Notification emails or dashboard log updates follow from that write.

## 14. What to Edit for Common Changes

If you are modifying the system, these are the usual touch points:

- Change who can sign in or what role means: [app/models/user.rb](../app/models/user.rb), [app/controllers/sessions_controller.rb](../app/controllers/sessions_controller.rb).
- Change dashboard access rules: [app/controllers/application_controller.rb](../app/controllers/application_controller.rb), [app/controllers/club_dashboard_controller.rb](../app/controllers/club_dashboard_controller.rb).
- Change what the public homepage shows: [app/controllers/ideathon_controller.rb](../app/controllers/ideathon_controller.rb) and its views.
- Change attendee management: [app/controllers/registered_attendees_controller.rb](../app/controllers/registered_attendees_controller.rb) and [app/models/registered_attendee.rb](../app/models/registered_attendee.rb).
- Change dashboard attendee/event reporting: [app/controllers/manager_controller.rb](../app/controllers/manager_controller.rb).
- Change audit log behavior: [app/models/activity_log.rb](../app/models/activity_log.rb), [app/services/activity_log_message.rb](../app/services/activity_log_message.rb), [app/models/manager_action_log.rb](../app/models/manager_action_log.rb).
- Change active year selection: [app/services/active_ideathon_year.rb](../app/services/active_ideathon_year.rb).

## 15. Closing Summary

The admin/dashboard system is the operational backend for the Ideathon site. It manages the year, the public content, the registration data, the event schedule, the audit trail, and user access.

If you understand these three things, you understand the system:

- `ideathon_years` is the parent record for public content,
- `users` controls who can access organizer tools,
- and the dashboard pages are just different views over the same shared data model that powers the public homepage.