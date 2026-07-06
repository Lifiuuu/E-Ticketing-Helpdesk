-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  full_name text,
  role text DEFAULT 'User'::text CHECK (role = ANY (ARRAY['Admin'::text, 'Helpdesk'::text, 'User'::text])),
  updated_at timestamp with time zone DEFAULT now(),
  is_active boolean DEFAULT true,
  phone_number text,
  avatar_url text,
  email text,
  fcm_token text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.tickets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  title text NOT NULL,
  description text,
  status text DEFAULT 'Open'::text CHECK (status = ANY (ARRAY['Open'::text, 'Assigned'::text, 'In Progress'::text, 'Resolved'::text, 'Closed'::text])),
  image_url text,
  created_at timestamp with time zone DEFAULT now(),
  assigned_to uuid,
  reporter_id uuid,
  is_deleted boolean DEFAULT false,
  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id),
  CONSTRAINT tickets_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.comments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  ticket_id uuid,
  user_id uuid,
  message text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT comments_pkey PRIMARY KEY (id),
  CONSTRAINT comments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  ticket_id uuid,
  title text NOT NULL,
  message text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  is_deleted boolean DEFAULT false,
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT notifications_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.ticket_attachments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  ticket_id uuid,
  file_url text NOT NULL,
  file_name text,
  file_size bigint,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ticket_attachments_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_attachments_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id)
);
CREATE TABLE public.ticket_history (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  ticket_id uuid,
  changed_by uuid,
  field_changed text NOT NULL,
  old_value text,
  new_value text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT ticket_history_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_history_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.profiles(id)
);