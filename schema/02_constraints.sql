-----------------------------------------------------------
-- USER TABLE
-----------------------------------------------------------
ALTER TABLE "user"
ADD CONSTRAINT fk_user_self
FOREIGN KEY (id)
REFERENCES "user"(id);

-----------------------------------------------------------
-- USER BADGE
-----------------------------------------------------------
ALTER TABLE user_badge
ADD CONSTRAINT fk_badge
FOREIGN KEY (badge_id)
REFERENCES badge(id);

ALTER TABLE user_badge
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id)
REFERENCES "user"(id);
