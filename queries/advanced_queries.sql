-----------------------------------------------------------
-- Asked queries
-----------------------------------------------------------
-- One request using at least three tables :
-- Get the average levels of all users buddies
WITH normalized AS (
  SELECT buddy_one_id AS user_id, buddy_two_id AS friend_id FROM buddies
  UNION ALL
  SELECT buddy_two_id AS user_id, buddy_one_id AS friend_id FROM buddies
)
SELECT
  u.id,
  AVG(l.challenge_creation_level) AS avg_creation,
  AVG(l.challenge_done_level)     AS avg_done,
  AVG(l.session_done_level)       AS avg_session,
  AVG(l.invitation_level)         AS avg_invitation
FROM users u
LEFT JOIN normalized n ON n.user_id = u.id
LEFT JOIN levels l ON l.user_id = n.friend_id
GROUP BY u.id;

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
) per_user;

-----------------------------------------------------------
-- QUERY USING EXTERNALS JOIN
-----------------------------------------------------------
SELECT
  u.id,
  COUNT(s.id) AS session_count
FROM users u
LEFT JOIN sessions s ON
  s.user_id = u.id
GROUP BY u.id;

-----------------------------------------------------------
-- TWO QUERIES USING TOTALITY CONDITIONS
-----------------------------------------------------------
-- Goal: users whose every session is at least 5 km long
-- Correlated sub query
select u.id
from users u
where exists (
  select *
  from sessions s
  where s.user_id = u.id
)
and not exists (
  select *
  from sessions s
  where s.user_id = u.id
    and s.distance < 5000
);

-- Aggregation
select s.user_id
from sessions s
group by s.user_id
having min(s.distance) >= 5000;

-----------------------------------------------------------
-- NULL DEPENDANT QUERIES
-----------------------------------------------------------
-- users who have never deleted another user
-- Not in form (breaks when deleted_by contains nulls)
select u.id
from users u
where u.id not in (
  select deleted_by from users
);

-- Not exists form (handles nulls correctly)
select u.id
from users u
where not exists (
  select *
  from users u2
  where u2.deleted_by = u.id
);

-- Fix for the first
select u.id
from users u
where u.id not in (
  select deleted_by from users where deleted_by is not null
);

-----------------------------------------------------------
-- RECURSIVE QUERIES
-----------------------------------------------------------
WITH RECURSIVE two_users_linked(buddy_one_id, buddy_two_id) AS (
  -- base : direct links
  SELECT
    buddy_one_id,
    buddy_two_id
  FROM buddies

  UNION

  -- recursion : propagation
  SELECT
    l.buddy_one_id,
    b.buddy_two_id
  FROM
    two_users_linked l
  JOIN buddies b ON
    l.buddy_two_id = b.buddy_one_id
)
SELECT EXISTS (
  SELECT *
  FROM two_users_linked
  WHERE buddy_one_id = 1
    AND buddy_two_id = 2
);

-----------------------------------------------------------
-- WINDOW FUNCTION
-----------------------------------------------------------
-- for each user, top 3 longest sessions in the last 90 days
select user_id, session_id, distance, start_datetime, dist_rank
from (
  select
    s.id as session_id,
    s.user_id,
    s.distance,
    s.start_datetime,
    row_number() over (
      partition by s.user_id
      order by s.distance desc nulls last
    ) as dist_rank
  from sessions s
  where s.start_datetime >= current_date - interval '90 days'
    and s.deleted_at is null
) ranked
where dist_rank <= 3
order by user_id, dist_rank;

-----------------------------------------------------------
-- TOP 5 CHALLENGES BY PARTICIPATION
-----------------------------------------------------------
-- most popular ongoing or upcoming challenges
select c.id, c.title, count(cm.user_id) as member_count
from challenges c
left join challenge_members cm on cm.challenge_id = c.id
where c.end_datetime >= current_timestamp
  and c.deleted_at is null
group by c.id, c.title
order by member_count desc
limit 5;

-----------------------------------------------------------
-- USERS RANKED BY TOTAL XP
-----------------------------------------------------------
-- leaderboard from the levels table
select
  u.id,
  u.first_name,
  u.last_name,
  l.challenge_creation_level
    + l.challenge_done_level
    + l.session_done_level
    + l.invitation_level as total_xp
from users u
join levels l on l.user_id = u.id
where u.deleted_at is null
order by total_xp desc
limit 10;

-----------------------------------------------------------
-- FRIEND-OF-FRIEND SUGGESTIONS
-----------------------------------------------------------
-- buddies of buddies who are not already direct buddies
with normalized as (
  select buddy_one_id as u1, buddy_two_id as u2 from buddies
  union all
  select buddy_two_id, buddy_one_id from buddies
)
select distinct n1.u1 as user_id, n2.u2 as suggested
from normalized n1
join normalized n2 on n2.u1 = n1.u2
where n2.u2 <> n1.u1
  and not exists (
    select * from normalized n3
    where n3.u1 = n1.u1 and n3.u2 = n2.u2
  );

-----------------------------------------------------------
-- SPORT CATEGORY DESCENDANTS
-----------------------------------------------------------
-- all sub-categories of a given root (e.g. cyclisme -> vtt -> enduro)
with recursive descendants as (
  select id, name, parent_id, tag_depth
  from sports_categories_tags
  where name = 'cyclisme'

  union all

  select c.id, c.name, c.parent_id, c.tag_depth
  from sports_categories_tags c
  join descendants d on c.parent_id = d.id
)
select * from descendants;
