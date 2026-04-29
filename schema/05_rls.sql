-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY users_select_policy
ON users
FOR SELECT
USING (deleted_at IS NULL);

CREATE POLICY users_insert_policy
ON users
FOR INSERT
WITH CHECK (deleted_at IS NULL);

CREATE POLICY users_update_policy
ON users
FOR UPDATE
USING (deleted_at IS NULL);

