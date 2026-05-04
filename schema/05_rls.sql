-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS users_policy ON users;

CREATE POLICY users_policy
ON users
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- FOLLOWERS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS followers_policy ON followers;

CREATE POLICY followers_policy
ON followers
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- BUDDIES TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS buddies_policy ON buddies;

CREATE POLICY buddies_policy
ON buddies
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- USERS BADGES TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS users_badges_policy ON users_badges;

CREATE POLICY users_badges_policy
ON users_badges
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- BADGES TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS badges_policy ON badges;

CREATE POLICY badges_policy
ON badges
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- SESSIONS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS sessions_policy ON sessions;

CREATE POLICY sessions_policy
ON sessions
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- TAGS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS tags_policy ON tags;

CREATE POLICY tags_policy
ON tags
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- OBJECTIVE TYPES TAGS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS objective_types_tags_policy ON objective_types_tags;

CREATE POLICY objective_types_tags_policy
ON objective_types_tags
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- HASHTAGS TAGS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS hashtags_tags_policy ON hashtags_tags;

CREATE POLICY hashtags_tags_policy
ON hashtags_tags
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- SPORTS CATEGORIES TAGS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS sports_categories_tags_policy ON sports_categories_tags;

CREATE POLICY sports_categories_tags_policy
ON sports_categories_tags
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- CHALLENGES TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS challenges_policy ON challenges;

CREATE POLICY challenges_policy
ON challenges
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- INVITATIONS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS invitations_policy ON invitations;

CREATE POLICY invitations_policy
ON invitations
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- DISPOSITIVES TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS dispositives_policy ON dispositives;

CREATE POLICY dispositives_policy
ON dispositives
FOR ALL
USING (deleted_at IS NULL)
WITH CHECK (deleted_at IS NULL);

-----------------------------------------------------------
-- CHALLENGES GOALS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS challenges_goals_policy ON challenges_goals;

CREATE POLICY challenges_goals_policy
ON challenges_goals
FOR ALL
USING (TRUE)
WITH CHECK (TRUE);

-----------------------------------------------------------
-- CHALLENGE MEMBERS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS challenge_members_policy ON challenge_members;

CREATE POLICY challenge_members_policy
ON challenge_members
FOR ALL
USING (TRUE)
WITH CHECK (TRUE);

-----------------------------------------------------------
-- CAPABILITIES TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS capabilities_policy ON capabilities;

CREATE POLICY capabilities_policy
ON capabilities
FOR ALL
USING (TRUE)
WITH CHECK (TRUE);

-----------------------------------------------------------
-- DISPOSITIVES CAPABILITIES TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS dispositives_capabilities_policy ON dispositives_capabilities;

CREATE POLICY dispositives_capabilities_policy
ON dispositives_capabilities
FOR ALL
USING (TRUE)
WITH CHECK (TRUE);

-----------------------------------------------------------
-- LEVELS TABLE
-----------------------------------------------------------
DROP POLICY IF EXISTS levels_policy ON levels;

CREATE POLICY levels_policy
ON levels
FOR ALL
USING (TRUE)
WITH CHECK (TRUE);
