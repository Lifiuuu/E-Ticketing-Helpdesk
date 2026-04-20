# Tasks: E-Ticketing Helpdesk (implementation plan)

## Phase 1 — Scaffold & Core
- [x] Create `openspec/changes/e-ticketing-helpdesk` artifacts (proposal/design/tasks).
- [ ] Add Clean Architecture folders under `lib/` (core, domain, data, presentation).
- [ ] Add Riverpod dependencies and initial provider wiring (Auth, Tickets, Notifications).
 - [x] Add Clean Architecture folders under `lib/` (core, domain, data, presentation).
 - [ ] Add Riverpod dependencies and initial provider wiring (Auth, Tickets, Notifications).

## Phase 2 — Authentication
- [ ] Implement Supabase-backed `AuthService` (signUp, signIn, resetPassword).
- [ ] On login, fetch `profiles.role` and store in app state.
- [ ] Ensure `register` creates a `profiles` row with default role `user` (DB trigger or direct insert).
 - [x] Implement Supabase-backed `AuthService` (signUp, signIn, resetPassword).
 - [x] On login, fetch `profiles.role` and store in app state.
 - [ ] Ensure `register` creates a `profiles` row with default role `user` (DB trigger or direct insert).
 - [x] Ensure `register` creates a `profiles` row with default role `user` (DB trigger or direct insert).

## Phase 3 — Dashboard & Profile
- [ ] Dashboard for staff: ticket counts by status and quick filters.
- [ ] Profile screen: show/edit user info and role (role editable only for admins).
 - [x] Dashboard for staff: ticket counts by status and quick filters.
 - [x] Profile screen: show/edit user info and role (role editable only for admins).

## Phase 4 — Ticket CRUD (User)
- [ ] Tickets list (lazy pagination) for current user.
- [ ] Create ticket with optional image upload to Supabase Storage.
- [ ] Ticket detail view with comments, attachments, and status timeline.
 - [x] Tickets list (lazy pagination) for current user.
 - [x] Create ticket with optional image upload to Supabase Storage.
 - [x] Ticket detail view with comments, attachments, and status timeline.

## Phase 5 — Admin / Helpdesk Features
- [ ] Tickets list (global) with status filters and search.
- [ ] Assign ticket to staff (`assigned_to`) and update ticket status.
- [ ] Create notifications on assign/status change.
 - [x] Tickets list (global) with status filters and search.
 - [x] Assign ticket to staff (`assigned_to`) and update ticket status.
 - [x] Create notifications on assign/status change.

## Phase 6 — Comments & Notifications
- [ ] Comments persisted to `comments` table.
- [ ] Notifications persisted to `notifications` table and shown in-app.
- [ ] Mark notifications as read.
 - [x] Comments persisted to `comments` table.
 - [x] Notifications persisted to `notifications` table and shown in-app.
 - [ ] Mark notifications as read.
 - [x] Mark notifications as read.

## Phase 7 — Security & DB
 - [x] Add RLS policies ensuring users see own tickets and staff can see all.
 - [x] Migrate or align DB schema (tickets/comments/notifications/profiles).

## Phase 8 — QA & Release
 - [x] Add unit and widget tests.
 - [ ] Run manual QA and fix UI polish.
 - [ ] Prepare release build and README with setup instructions.

