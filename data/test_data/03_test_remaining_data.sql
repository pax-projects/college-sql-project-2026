-----------------------------------------------------------
-- OBJECTIVE TYPE TAGS
-----------------------------------------------------------
insert into objective_types_tags (name, unit, created_by, updated_by, created_at, updated_at)
values ('distance',    'm',    1, 1, current_timestamp, current_timestamp),
       ('elevation',   'm',    1, 1, current_timestamp, current_timestamp),
       ('time',        's',    1, 1, current_timestamp, current_timestamp),
       ('active_days', 'days', 1, 1, current_timestamp, current_timestamp);

-----------------------------------------------------------
-- HASHTAG TAGS
-----------------------------------------------------------
insert into hashtags_tags (name, created_by, updated_by, created_at, updated_at)
values ('lac',               1, 1, current_timestamp, current_timestamp),
       ('soleil',            1, 1, current_timestamp, current_timestamp),
       ('sombre',            1, 1, current_timestamp, current_timestamp),
       ('trail',             1, 1, current_timestamp, current_timestamp),
       ('randonneemontagne', 1, 1, current_timestamp, current_timestamp),
       ('ecochallenge',      1, 1, current_timestamp, current_timestamp),
       ('pluvieux',          1, 1, current_timestamp, current_timestamp),
       ('nocturne',          1, 1, current_timestamp, current_timestamp);

-----------------------------------------------------------
-- SPORTS CATEGORY HIERARCHY
-----------------------------------------------------------
insert into sports_categories_tags (name, parent_id, created_by, updated_by, created_at, updated_at)
values ('cyclisme',      null, 1, 1, current_timestamp, current_timestamp),
       ('course-a-pied', null, 1, 1, current_timestamp, current_timestamp),
       ('natation',      null, 1, 1, current_timestamp, current_timestamp),
       ('randonnee',     null, 1, 1, current_timestamp, current_timestamp),
       ('kayak',         null, 1, 1, current_timestamp, current_timestamp);

-- Children of cyclisme
insert into sports_categories_tags (name, parent_id, created_by, updated_by, created_at, updated_at)
select 'vtt',   id, 1, 1, current_timestamp, current_timestamp from sports_categories_tags where name = 'cyclisme';
insert into sports_categories_tags (name, parent_id, created_by, updated_by, created_at, updated_at)
select 'route', id, 1, 1, current_timestamp, current_timestamp from sports_categories_tags where name = 'cyclisme';

-- Grandchildren of cyclisme (children of vtt)
insert into sports_categories_tags (name, parent_id, created_by, updated_by, created_at, updated_at)
select 'enduro',        id, 1, 1, current_timestamp, current_timestamp from sports_categories_tags where name = 'vtt';
insert into sports_categories_tags (name, parent_id, created_by, updated_by, created_at, updated_at)
select 'cross-country', id, 1, 1, current_timestamp, current_timestamp from sports_categories_tags where name = 'vtt';

-- Children of course-a-pied
insert into sports_categories_tags (name, parent_id, created_by, updated_by, created_at, updated_at)
select 'trail-running', id, 1, 1, current_timestamp, current_timestamp from sports_categories_tags where name = 'course-a-pied';
insert into sports_categories_tags (name, parent_id, created_by, updated_by, created_at, updated_at)
select 'marathon',      id, 1, 1, current_timestamp, current_timestamp from sports_categories_tags where name = 'course-a-pied';

-----------------------------------------------------------
-- CHALLENGES
-----------------------------------------------------------
do $$
declare
  i integer;
  owner integer;
  start_dt timestamp;
  end_dt timestamp;
  collective boolean;
  cap integer;
begin
  for i in 1..50 loop
    select id into owner from users where deleted_at is null order by random() limit 1;
    start_dt := current_timestamp - (random() * 30 || ' days')::interval;
    end_dt   := start_dt + ((random() * 30 + 7) || ' days')::interval;
    collective := random() < 0.5;
    if collective then
      cap := (random() * 20)::int + 5;
    else
      cap := null;
    end if;

    insert into challenges (owner_id, title, description, start_datetime, end_datetime, is_collective, capacity_max, created_by)
    values (owner, 'challenge #' || i, 'description for challenge ' || i, start_dt, end_dt, collective, cap, owner);
  end loop;
end $$;

-----------------------------------------------------------
-- CHALLENGES GOALS
-----------------------------------------------------------
do $$
declare
  c record;
  dist_id integer;
  elev_id integer;
  conditions text[] := array['greater_or_equal', 'greater_than', 'less_or_equal', 'less_than', 'equal'];
begin
  select id into dist_id from objective_types_tags where name = 'distance';
  select id into elev_id from objective_types_tags where name = 'elevation';

  for c in select id from challenges loop
    insert into challenges_goals (challenge_id, objective_type_id, targeted_value, condition)
    values (c.id, dist_id, (random() * 50000 + 1000)::float,
            conditions[floor(random() * 5)::int + 1])
    on conflict do nothing;

    if random() < 0.4 then
      insert into challenges_goals (challenge_id, objective_type_id, targeted_value, condition)
      values (c.id, elev_id, (random() * 2000 + 100)::float, 'greater_or_equal')
      on conflict do nothing;
    end if;
  end loop;
end $$;

-----------------------------------------------------------
-- CHALLENGE MEMBERS (owner is always a member)
-----------------------------------------------------------
do $$
declare
  c record;
  j integer;
  uid integer;
  n integer;
begin
  for c in select id, owner_id, is_collective, capacity_max from challenges loop
    begin
      insert into challenge_members (user_id, challenge_id) values (c.owner_id, c.id)
      on conflict do nothing;
    exception when others then
      null;
    end;

    if c.is_collective then
      n := least(coalesce(c.capacity_max, 5) - 1, (random() * 8)::int);
    else
      n := (random() * 5)::int;
    end if;

    for j in 1..n loop
      select id into uid from users where deleted_at is null and id <> c.owner_id order by random() limit 1;
      begin
        insert into challenge_members (user_id, challenge_id) values (uid, c.id)
        on conflict do nothing;
      exception when others then
        null;
      end;
    end loop;
  end loop;
end $$;

-----------------------------------------------------------
-- SESSIONS (with ~10% null distance for the null-dependent tests)
-----------------------------------------------------------
do $$
declare
  i integer;
  uid integer;
  st timestamp;
  dur integer;
  dist numeric;
  hd numeric;
  ms numeric;
  vs numeric;
  xs numeric;
begin
  for i in 1..500 loop
    select id into uid from users where deleted_at is null order by random() limit 1;
    st  := current_timestamp - (random() * 90 || ' days')::interval;
    dur := (random() * 7200)::int + 600;

    if random() < 0.1 then
      dist := null;
    else
      dist := (random() * 30000)::numeric(10,2);
    end if;

    hd := (random() * 1000)::numeric(10,2);
    ms := (random() * 5)::numeric(10,2);
    xs := ms + (random() * 10)::numeric(10,2);
    vs := (ms + xs) / 2;

    insert into sessions (user_id, start_datetime, end_datetime,
                          distance, height_diff, avg_speed, min_speed, max_speed,
                          created_by, updated_by, created_at, updated_at)
    values (uid, st, st + (dur || ' seconds')::interval,
            dist, hd, vs, ms, xs,
            uid, uid, current_timestamp, current_timestamp);
  end loop;
end $$;

-----------------------------------------------------------
-- INVITATIONS
-----------------------------------------------------------
do $$
declare
  c record;
  j integer;
  invited integer;
  st text;
  statuses text[] := array['sent', 'accepted', 'refused', 'no_reply'];
begin
  for c in select id, owner_id from challenges order by random() limit 30 loop
    for j in 1..((random() * 4)::int + 1) loop
      select id into invited from users where deleted_at is null and id <> c.owner_id order by random() limit 1;
      st := statuses[floor(random() * 4)::int + 1];
      insert into invitations (inviter_id, invited_id, challenge_id, status, created_by)
      values (c.owner_id, invited, c.id, st, c.owner_id);
    end loop;
  end loop;
end $$;

-----------------------------------------------------------
-- BADGES
-----------------------------------------------------------
insert into badges (name, created_by) values
  ('first session',     1),
  ('challenge starter', 1),
  ('marathoner',        1),
  ('challenger',        1),
  ('mountain goat',     1),
  ('early bird',        1),
  ('night owl',         1),
  ('social butterfly',  1);

-----------------------------------------------------------
-- USERS BADGES
-----------------------------------------------------------
do $$
declare
  i integer;
  uid integer;
  bid integer;
begin
  for i in 1..200 loop
    select id  into uid from users  where deleted_at is null order by random() limit 1;
    select id  into bid from badges order by random() limit 1;
    insert into users_badges (user_id, badge_id, obtention_date, created_by)
    values (uid, bid, current_timestamp - (random() * 60 || ' days')::interval, uid)
    on conflict do nothing;
  end loop;
end $$;

-----------------------------------------------------------
-- CAPABILITIES
-----------------------------------------------------------
insert into capabilities (name, unit) values
  ('heart rate',  'bpm'),
  ('gps',         null),
  ('cadence',     'rpm'),
  ('temperature', 'C'),
  ('barometer',   'hPa'),
  ('power meter', 'W');

-----------------------------------------------------------
-- DISPOSITIVES + DISPOSITIVES_CAPABILITIES
-----------------------------------------------------------
do $$
declare
  i integer;
  uid integer;
  d_id integer;
  cap_id integer;
  j integer;
  brand text;
  brands text[] := array['Garmin', 'Polar', 'Suunto', 'Coros', 'Wahoo'];
begin
  for i in 1..80 loop
    select id into uid from users where deleted_at is null order by random() limit 1;
    brand := brands[floor(random() * 5)::int + 1];

    insert into dispositives (user_id, name, brand, model, created_by)
    values (uid, brand || ' watch', brand, 'model-' || i, uid)
    returning id into d_id;

    for j in 1..((random() * 3)::int + 1) loop
      select id into cap_id from capabilities order by random() limit 1;
      insert into dispositives_capabilities (dispositive_id, capability_id)
      values (d_id, cap_id)
      on conflict do nothing;
    end loop;
  end loop;
end $$;

-----------------------------------------------------------
-- SESSION MEASUREMENTS
-----------------------------------------------------------
do $$
declare
  i integer;
  sid integer;
  cap_id integer;
  cap_name text;
  val numeric;
begin
  for i in 1..800 loop
    select id into sid from sessions order by random() limit 1;
    select id, name into cap_id, cap_name from capabilities order by random() limit 1;

    val := case cap_name
      when 'heart rate'  then (random() * 80 + 80)::numeric(10,2)
      when 'cadence'     then (random() * 100)::numeric(10,2)
      when 'temperature' then (random() * 35 - 5)::numeric(10,2)
      when 'barometer'   then (random() * 100 + 950)::numeric(10,2)
      when 'power meter' then (random() * 400 + 50)::numeric(10,2)
      else null
    end;

    if val is not null then
      insert into session_measurements (session_id, capability_id, value)
      values (sid, cap_id, val)
      on conflict do nothing;
    end if;
  end loop;
end $$;

-----------------------------------------------------------
-- SESSION HASHTAGS
-----------------------------------------------------------
do $$
declare
  i integer;
  sid integer;
  hid integer;
begin
  for i in 1..600 loop
    select id into sid from sessions order by random() limit 1;
    select id into hid from hashtags_tags order by random() limit 1;
    insert into session_hashtags (session_id, hashtag_id)
    values (sid, hid) on conflict do nothing;
  end loop;
end $$;

-----------------------------------------------------------
-- CHALLENGE HASHTAGS
-----------------------------------------------------------
do $$
declare
  c record;
  j integer;
  hid integer;
begin
  for c in select id from challenges loop
    for j in 1..((random() * 3)::int + 1) loop
      select id into hid from hashtags_tags order by random() limit 1;
      insert into challenge_hashtags (challenge_id, hashtag_id)
      values (c.id, hid) on conflict do nothing;
    end loop;
  end loop;
end $$;

-----------------------------------------------------------
-- CHALLENGE CATEGORIES
-----------------------------------------------------------
do $$
declare
  c record;
  j integer;
  sc_id integer;
begin
  for c in select id from challenges loop
    for j in 1..((random() * 2)::int + 1) loop
      select id into sc_id from sports_categories_tags order by random() limit 1;
      insert into challenge_categories (challenge_id, sport_category_id)
      values (c.id, sc_id) on conflict do nothing;
    end loop;
  end loop;
end $$;

-----------------------------------------------------------
-- LEVELS
-----------------------------------------------------------
insert into levels (user_id, challenge_creation_level, challenge_done_level, session_done_level, invitation_level)
select id,
       (random() * 10)::int,
       (random() * 10)::int,
       (random() * 20)::int,
       (random() * 5)::int
from users where deleted_at is null
on conflict do nothing;

-----------------------------------------------------------
-- A FEW NON-NULL deleted_by VALUES (helps demonstrate the
-- null-dependent queries: NOT IN vs NOT EXISTS divergence)
-----------------------------------------------------------
update users set deleted_by = 1 where id in (235, 236, 237);
update users set deleted_by = 2 where id = 238;
