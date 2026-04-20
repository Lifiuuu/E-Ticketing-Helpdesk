-- RLS policies for E-Ticketing Helpdesk
-- Enable row-level security and add policies so:
-- - Users see only their own tickets/comments/notifications
-- - Staff (role = 'admin') can see all tickets

-- Enable RLS
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Policy: owners can select their own tickets
CREATE POLICY select_own_tickets ON tickets
  USING (user_id = current_setting('jwt.claims.user_id')::uuid OR
         EXISTS (SELECT 1 FROM profiles p WHERE p.id = current_setting('jwt.claims.user_id')::uuid AND p.role = 'admin'));

-- Policy: owners can insert (users create tickets)
CREATE POLICY insert_tickets ON tickets
  FOR INSERT
  WITH CHECK (user_id = current_setting('jwt.claims.user_id')::uuid);

-- Policy: allow updates by admin or assignee
CREATE POLICY update_tickets ON tickets
  FOR UPDATE
  USING (EXISTS (SELECT 1 FROM profiles p WHERE p.id = current_setting('jwt.claims.user_id')::uuid AND p.role = 'admin')
         OR assigned_to = current_setting('jwt.claims.user_id')::uuid);

-- Comments: owners and admin
CREATE POLICY select_own_comments ON comments
  USING (user_id = current_setting('jwt.claims.user_id')::uuid OR
         EXISTS (SELECT 1 FROM profiles p WHERE p.id = current_setting('jwt.claims.user_id')::uuid AND p.role = 'admin'));

CREATE POLICY insert_comments ON comments
  FOR INSERT
  WITH CHECK (user_id = current_setting('jwt.claims.user_id')::uuid);

-- Notifications: only target user and admin can see
CREATE POLICY select_notifications ON notifications
  USING (user_id = current_setting('jwt.claims.user_id')::uuid OR
         EXISTS (SELECT 1 FROM profiles p WHERE p.id = current_setting('jwt.claims.user_id')::uuid AND p.role = 'admin'));

CREATE POLICY insert_notifications ON notifications
  FOR INSERT
  WITH CHECK (user_id = current_setting('jwt.claims.user_id')::uuid);
