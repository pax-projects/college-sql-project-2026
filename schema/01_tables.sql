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
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
CREATE TABLE IF NOT EXISTS tags (
  id                SERIAL PRIMARY KEY,
  name              VARCHAR(30) UNIQUE NOT NULL,
  description       TEXT,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER NOT NULL,
  deleted_by        INTEGER,
  created_at        TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP
);

CREATE TABLE IF NOT EXISTS objective_types_tags (
  unit              VARCHAR(50) NOT NULL,

  PRIMARY KEY (id)
) INHERITS (tags);

CREATE TABLE IF NOT EXISTS hashtags_tags (
  PRIMARY KEY (id)

) INHERITS (tags);

CREATE TABLE IF NOT EXISTS sports_categories_tags (
  parent_id         INTEGER,
  tag_depth         INTEGER NOT NULL DEFAULT 0,

  PRIMARY KEY (id)
) INHERITS (tags);

-----------------------------------------------------------
-- CHALLENGES TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS challenges (
  id                SERIAL PRIMARY KEY,
  owner_id          INTEGER NOT NULL,
  title             VARCHAR(255) NOT NULL,
  description       TEXT,

  start_datetime    TIMESTAMP NOT NULL,
  end_datetime      TIMESTAMP NOT NULL,

  is_collective     BOOLEAN NOT NULL DEFAULT FALSE,
  capacity_max      INTEGER,
 
  created_by        INTEGER NOT NULL,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP
);

CREATE TABLE IF NOT EXISTS challenges_goals (
  id                SERIAL PRIMARY KEY,
  challenge_id      INTEGER NOT NULL,
  objective_type_id INTEGER NOT NULL,
  targeted_value    FLOAT NOT NULL,
  condition         TEXT NOT NULL DEFAULT 'greater_or_equal',

  UNIQUE (challenge_id, objective_type_id)
);

