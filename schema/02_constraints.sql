-----------------------------------------------------------
-- USER TABLE
-----------------------------------------------------------
ALTER TABLE "user"
ADD CONSTRAINT fk_user_self
FOREIGN KEY (id)
REFERENCES "user"(id);
