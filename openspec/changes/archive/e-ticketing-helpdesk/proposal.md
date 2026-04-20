# Proposal: E-Ticketing Helpdesk (Mobile)

## What
Build a production-ready E‑Ticketing Helpdesk mobile app (Flutter) that lets end users file tickets, and helpdesk/admin staff view, assign, comment, and change ticket statuses. The app will use Supabase for Auth, Postgres tables, Storage, and Row-Level Security (RLS).

## Why
- Replace the current prototype with a hardened, backend-backed mobile app.
- Enforce server-side security (RLS) so users can only access their own tickets.
- Provide role-based access for Staff (Admin/Helpdesk) and Users.
- Deliver a maintainable codebase using Clean Architecture and Riverpod for state.

## Scope
- Mobile frontend in Flutter (clean architecture) with Riverpod state management.
- Supabase backend usage for Auth, DB (tickets, comments, notifications, profiles), Storage for attachments.
- Features: auth (login/register/reset), ticket create/list/detail, comments, assignment, status updates, in-app notifications, basic admin dashboard and filters.

## Success Criteria
- Users can register/login and have `profiles.role` set to `user` by default.
- Users see only their tickets; staff sees all tickets.
- Ticket lifecycle supports Open → In Progress → Resolved → Closed.
- Comments and notifications recorded in their respective normalized tables.
- RLS policies in Supabase enforce data access rules.

## Risks
- Schema mismatch between app assumptions and existing DB requires careful mapping.
- Native plugin issues require full rebuilds (not hot-reload) during development.

## Stakeholders
- Product owner / PM
- Mobile developer(s)
- Backend (Supabase) admin

