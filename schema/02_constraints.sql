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
