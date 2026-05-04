-----------------------------------------------------------
-- Asked queries
-----------------------------------------------------------
-- One request using at least three tables :
-- Get all the average levels of all buddies of specific user
-- SELECT
--   challenge_creation_level,
--   challenge_done_level,
--   session_done_level,
--   invitation_level
-- FROM levels
-- JOIN buddies ON
--   buddies.buddy_one_id = levels.user_id
-- JOIN users ON
--   buddies.buddy_two_id = users.id
--
-- UNION
--
-- SELECT
--   challenge_creation_level,
--   challenge_done_level,
--   session_done_level,
--   invitation_level
-- FROM levels
-- JOIN buddies ON
--   buddies.buddy_two_id = levels.user_id
-- JOIN users ON
--   buddies.buddy_one_id = users.id;
--
-- SELECT AVG(levels.challenge_creation_level)
-- FROM users
-- JOIN buddies ON
--   buddies.buddy_one_id = users.id OR
--   buddies.buddy_two_id = users.id
-- JOIN levels ON

-----------------------------------------------------------
-- SELF-JOINED QUERY
-----------------------------------------------------------
-- Goal: Check that the followers table DOES NOT contain two tuples
-- as follow (A -> B) and (B -> A) where "A" and "B" are users and "->"
-- represents the following relationship.
-- If COUNT gives us a 0 it's wonderfull, otherwise, our triggers do not work...
SELECT COUNT(*)
FROM followers f1             -- NOTE: Vroom Vroom
JOIN followers f2 ON
  f1.followed_id = f2.follower_id;

-----------------------------------------------------------
-- CORRELATED SUBQUERY
-----------------------------------------------------------
-- Goal: Select all last users' session
SELECT *
FROM sessions s
WHERE s.start_datetime = (
  SELECT MAX(s2.start_datetime)
  FROM sessions s2
  WHERE s2.user_id = s.user_id
);

-----------------------------------------------------------
-- DERIVED TABLE
-----------------------------------------------------------
-- Goal: Calculates users statistics
SELECT
  u.id,
  u.first_name,
  u.last_name,
  stats.total_distance,
  stats.session_count,
  stats.avg_max_speed,
  stats.avg_min_speed,
  stats.avg_speed
FROM users u
JOIN (
  SELECT
    user_id,
    COUNT(*) AS session_count,
    SUM(distance) AS total_distance,
    AVG(max_speed) AS avg_max_speed,
    AVG(min_speed) AS avg_min_speed,
    AVG(avg_speed) AS avg_speed
  FROM sessions
  GROUP BY user_id
) stats ON
  stats.user_id = u.id;

-----------------------------------------------------------
-- SUBQUERY IN WHERE CLAUSE
-----------------------------------------------------------
-- Goal: Select all users having done at least one session
SELECT
  u.id,
  u.first_name,
  u.last_name
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM sessions s
  WHERE s.user_id = u.id
);

-----------------------------------------------------------
-- TWO AGGREATES USING GROUP BY AND HAVING
-----------------------------------------------------------
SELECT
  user_id,
  AVG(distance) AS avg_distance,
  AVG(height_diff) AS avg_height_diff
FROM sessions
GROUP BY user_id
HAVING
  AVG(distance) > 1000 AND
  AVG(height_diff) > 300;

-----------------------------------------------------------
-- QUERY USING CALCULATING WITH TWO AGGREGATES
-----------------------------------------------------------
SELECT
  AVG(max_distance) AS avg_max_distance
FROM (
  SELECT
    MAX(distance) AS max_distance
  FROM sessions
  GROUP BY user_id
);

-----------------------------------------------------------
-- QUERY USING EXTERNALS JOIN
-----------------------------------------------------------
SELECT
  u.id,
  COUNT(s.id) AS session_count
FROM users u
LEFT JOIN sessions s ON
  all_sessions.user_id = u.id
GROUP BY u.id;

-----------------------------------------------------------
-- TWO QUERIES USING TOTALITY CONDITIONS
-----------------------------------------------------------
-- Correlated sub query
SELECT u.id
FROM users u
WHERE EXISTS (
  SELECT 1
  FROM sessions s
  WHERE s.user_id = u.id
);

-- Aggregation
SELECT u.id
FROM users u
JOIN sessions s ON
  s.user_id = u.id
GROUP BY u.id
HAVING COUNT(s.id) > 0;
