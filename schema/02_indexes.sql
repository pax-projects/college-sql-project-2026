-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
CREATE INDEX idx_users_not_deleted
ON users(id)
WHERE deleted_at IS NULL;

-----------------------------------------------------------
-- FOLLOWERS TABLE
-----------------------------------------------------------
CREATE INDEX idx_followers_not_deleted
ON followers(follower_id, followed_id)
WHERE deleted_at IS NULL;

-----------------------------------------------------------
-- BUDDIES TABLE
-----------------------------------------------------------
CREATE INDEX idx_buddies_not_deleted
ON buddies(buddy_one_id, buddy_two_id)
WHERE deleted_at IS NULL;
