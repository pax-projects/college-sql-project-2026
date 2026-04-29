-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
-- CREATE :
INSERT INTO users (first_name, last_name, email)
VALUES ('Jean-Paul', 'Sartre', 'popol.sartre@email.com');

-- READ   :
SELECT * FROM users
WHERE
  first_name = 'Jean%' AND
  last_name  = 'Sartre';

-- UPDATE :
UPDATE users
SET
  email = 'jean-paul.sartre@email.com'
WHERE
  first_name = 'Jean-Paul' AND
  last_name  = 'Sartre';

-- (Soft) DELETE :
UPDATE users
SET
  deleted_at = CURRENT_TIMESTAMP
WHERE
  email = 'jean-paul.sartre@email.com';

-- (Hard) DELETE :
DELETE FROM users
WHERE
  email = 'jean-paul.sartre@email.com';

-----------------------------------------------------------
-- BUDDIES TABLE
-----------------------------------------------------------
-- CREATE :
INSERT INTO followers (follower_id, followed_id)
VALUES (1, 2);

SELECT * FROM followers;

INSERT INTO followers (follower_id, followed_id)
VALUES (2, 1);

SELECT * FROM followers;

SELECT * FROM buddies;
