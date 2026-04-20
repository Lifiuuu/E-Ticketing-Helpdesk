# Design: E-Ticketing Helpdesk (Mobile)

## High-level Architecture
- Presentation: Flutter UI (screens, widgets) following Clean Architecture boundaries.
- State: Riverpod for global state, auth, and ticket repositories.
- Data: Supabase client (Auth + Postgres + Storage). Data access goes through repository adapters in `data/`.
- Notification: In-app banner + persisted `notifications` table for history.

## Data Model (summary)
- `profiles` (id uuid PK, full_name, role enum {User, Helpdesk, Admin}, ...)
- `tickets` (id uuid PK, user_id fk, title, description, status enum, image_url, created_at, assigned_to uuid)
- `comments` (id uuid PK, ticket_id fk, user_id fk, message, created_at)
- `notifications` (id uuid PK, user_id fk, ticket_id fk, title, message, is_read bool, created_at)

## Supabase Integration
- Auth: `signUp`, `signInWithPassword`, `resetPasswordForEmail`.
- DB: Use `.from('...')` queries via `supabase_flutter`; prefer `maybeSingle()` and explicit casting to `Map<String,dynamic>`.
- Storage: store attachments using Supabase Storage and save returned URL to `tickets.image_url`.
- RLS: Database policies must prevent cross-user access and allow staff roles to read/write as appropriate.

## Key Flows
- Login: authenticate via Supabase, then fetch `profiles` row to read `role` and persist in app state.
- Register: sign up via Supabase; DB trigger or server function populates `profiles` with default `role='user'`.
- Create Ticket: upload attachment (optional) → insert into `tickets` with `user_id` → create initial notification for staff.
- Comment: insert row into `comments` and optionally create `notifications` for ticket assignee/owner.
- Assign / Status change: update `tickets.assigned_to` and/or `status`, insert `notifications` and show in-app banner.

## UI / Navigation
- Use declarative routing (GoRouter) with paths: `/`, `/login`, `/register`, `/home`, `/tickets`, `/ticket/:id`, `/profile`.
- Screens: Splash, Login, Register, Dashboard, TicketsList, TicketDetail, CreateTicket, Profile, AdminFilters.

## Error Handling & UX
- Show toasts/snackbars for success/failure of network ops.
- Retry logic for uploads and resilient network access.

## Tests
- Unit tests for repositories and mapping functions.
- Widget tests for core screens (login, ticket list, create ticket).

