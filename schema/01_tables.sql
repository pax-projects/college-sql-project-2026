-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id                SERIAL PRIMARY KEY,
  first_name        VARCHAR(50) NOT NULL,
  last_name         VARCHAR(50) NOT NULL,
  email             VARCHAR(256) NOT NULL,
  total_points      INTEGER DEFAULT 0,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER NOT NULL,
  deleted_by        INTEGER,
  created_at        TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP
);

-----------------------------------------------------------
-- FOLLOWERS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS followers (
  follower_id       INTEGER NOT NULL,
  followed_id       INTEGER NOT NULL,

  PRIMARY KEY (follower_id, followed_id),

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER NOT NULL,
  deleted_by        INTEGER,
  created_at        TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP
);

-----------------------------------------------------------
-- BUDDIES TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS buddies (
  buddy_one_id      INTEGER NOT NULL,
  buddy_two_id      INTEGER NOT NULL,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER NOT NULL,
  deleted_by        INTEGER,
  created_at        TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP
);

-----------------------------------------------------------
-- USERS BADGES TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS badges (
  id                SERIAL PRIMARY KEY,
  name              VARCHAR(50) NOT NULL,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER NOT NULL,
  deleted_by        INTEGER,
  created_at        TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users_badges (
  badge_id          INTEGER NOT NULL,
  user_id           INTEGER NOT NULL,
  obtention_date    TIMESTAMP NOT NULL,

  PRIMARY KEY (badge_id, user_id)
);

-----------------------------------------------------------
-- SESSIONS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS sessions (
  id                SERIAL PRIMARY KEY,
  user_id           INTEGER NOT NULL,
  start_datetime    TIMESTAMP NOT NULL,
  end_datetime      TIMESTAMP NOT NULL,
  distance          NUMERIC,
  height_diff       NUMERIC,
  avg_speed         NUMERIC,
  min_speed         NUMERIC,
  max_speed         NUMERIC,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER NOT NULL,
  deleted_by        INTEGER,
  created_at        TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP
);

-----------------------------------------------------------
-- TAGS TABLE
-----------------------------------------------------------
-- TODO: Revoke modification rights
-- WARNING: The next integers are set in data/seed.sql
CREATE TABLE IF NOT EXISTS tags_types (
  id                SERIAL PRIMARY KEY,
  name              VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS tags (
  id                SERIAL,
  tag_type          INTEGER NOT NULL,
  parent_id         INTEGER,
  tag_depth         INTEGER NOT NULL DEFAULT 0,
  name              VARCHAR(30) NOT NULL,
  description       TEXT,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER NOT NULL,
  deleted_by        INTEGER,
  created_at        TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP,

  PRIMARY KEY (id, tag_type),
  UNIQUE (name, tag_type)
) PARTITION BY LIST (tag_type);

CREATE TABLE objective_types_tags
PARTITION OF tags
FOR VALUES IN (1);

CREATE TABLE hashtags_tags
PARTITION OF tags
FOR VALUES IN (2);

CREATE TABLE sports_categories_tags
PARTITION OF tags
FOR VALUES IN (3);

