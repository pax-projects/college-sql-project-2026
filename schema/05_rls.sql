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

-----------------------------------------------------------
-- FOLLOWERS TABLE
-----------------------------------------------------------
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;

CREATE POLICY followers_select_policy
ON followers
FOR SELECT
USING (deleted_at IS NULL);

CREATE POLICY followers_insert_policy
ON followers
FOR INSERT
WITH CHECK (deleted_at IS NULL);

CREATE POLICY followers_update_policy
ON followers
FOR UPDATE
USING (deleted_at IS NULL);

-----------------------------------------------------------
-- BUDDIES TABLE
-----------------------------------------------------------
ALTER TABLE buddies ENABLE ROW LEVEL SECURITY;

CREATE POLICY buddies_select_policy
ON buddies
FOR SELECT
USING (deleted_at IS NULL);

CREATE POLICY buddies_insert_policy
ON buddies
FOR INSERT
WITH CHECK (deleted_at IS NULL);

CREATE POLICY buddies_update_policy
ON buddies
FOR UPDATE
USING (deleted_at IS NULL);

