-----------------------------------------------------------
-- Simple CRUD on users table
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
-- Asked queries
-----------------------------------------------------------
-- One request using at least three tables :
-- Get all the average levels of all buddies of specific user
SELECT
  challenge_creation_level,
  challenge_done_level,
  session_done_level,
  invitation_level
FROM levels
JOIN buddies ON
  buddies.buddy_one_id = levels.user_id
JOIN users ON
  buddies.buddy_two_id = users.id

UNION

SELECT
  challenge_creation_level,
  challenge_done_level,
  session_done_level,
  invitation_level
FROM levels
JOIN buddies ON
  buddies.buddy_two_id = levels.user_id
JOIN users ON
  buddies.buddy_one_id = users.id;

SELECT AVG(levels.challenge_creation_level)
FROM users
JOIN buddies ON
  buddies.buddy_one_id = users.id OR
  buddies.buddy_two_id = users.id
JOIN levels ON
  
