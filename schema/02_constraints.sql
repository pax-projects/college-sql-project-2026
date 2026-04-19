-----------------------------------------------------------
-- USERS CONSTRAINTS
-----------------------------------------------------------
ALTER TABLE users
ADD CONSTRAINT fk_user_self
FOREIGN KEY (id)
REFERENCES users(id);

-----------------------------------------------------------
-- FOLLOWER CONSTRAINTS
-----------------------------------------------------------
ALTER TABLE followers
ADD CONSTRAINT fk_follower_user
FOREIGN KEY (follower_id)
REFERENCES users(id);

ALTER TABLE followers
ADD CONSTRAINT fk_followed_user
FOREIGN KEY (followed_id)
REFERENCES users(id);

-----------------------------------------------------------
-- BUDDIES CONSTRAINTS
-----------------------------------------------------------
ALTER TABLE buddies
ADD CONSTRAINT fk_buddy_one_user
FOREIGN KEY (buddy_one_id)
REFERENCES users(id);

ALTER TABLE buddies
ADD CONSTRAINT fk_buddy_two_user
FOREIGN KEY (buddy_two_id)
REFERENCES users(id);

-----------------------------------------------------------
-- USER BADGE CONSTRAINTS
-----------------------------------------------------------
ALTER TABLE users_badges
ADD CONSTRAINT fk_badge
FOREIGN KEY (badge_id)
REFERENCES badges(id);

ALTER TABLE users_badges
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES users(id);

-----------------------------------------------------------
-- SESSIONS TABLE
-----------------------------------------------------------
ALTER TABLE sessions
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES users(id);

-- checks: distance >= 0
ALTER TABLE sessions
ADD CONSTRAINT chk_distance_geq_zero
CHECK (distance >= 0);

-- checks: height_diff >= 0
ALTER TABLE sessions
ADD CONSTRAINT chk_height_diff_geq_zero
CHECK (height_diff >= 0);

-- checks: avg_speed, max_speed, min_speed >= 0
ALTER TABLE sessions
ADD CONSTRAINT chk_avg_speed_geq_zero
CHECK (avg_speed >= 0);

ALTER TABLE sessions
ADD CONSTRAINT chk_min_speed_geq_zero
CHECK (min_speed >= 0);

ALTER TABLE sessions
ADD CONSTRAINT chk_max_speed_geq_zero
CHECK (max_speed >= 0);

-- checks: min_speed <= avg_speed <= max_speed
ALTER TABLE sessions
ADD CONSTRAINT chk_min_leq_avg_leq_max_speed
CHECK (min_speed <= avg_speed AND avg_speed <= max_speed);  -- Does accept nulls values

-- checks: start_datetime < end_datetime
ALTER TABLE sessions
ADD CONSTRAINT chk_start_le_end_datetime
CHECK (start_datetime < end_datetime);                      -- A session stays at least > 0 seconds
