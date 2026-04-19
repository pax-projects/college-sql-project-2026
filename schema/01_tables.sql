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

  PRIMARY KEY (follower_id, followed_id)
);

-----------------------------------------------------------
-- BUDDIES TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS buddies (
  buddy_one_id      INTEGER NOT NULL,
  buddy_two_id      INTEGER NOT NULL
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

