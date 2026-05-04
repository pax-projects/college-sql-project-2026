-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id                SERIAL PRIMARY KEY,
  first_name        VARCHAR(50) NOT NULL,
  last_name         VARCHAR(50) NOT NULL,
  email             VARCHAR(256) UNIQUE NOT NULL,
  total_points      INTEGER DEFAULT 0,

  created_by        INTEGER,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP,

  CONSTRAINT fk_users_created_by
    FOREIGN KEY (created_by)
    REFERENCES users(id),

  CONSTRAINT fk_users_updated_by
    FOREIGN KEY (updated_by)
    REFERENCES users(id),

  CONSTRAINT fk_users_deleted_by
    FOREIGN KEY (deleted_by)
    REFERENCES users(id)
);

-----------------------------------------------------------
-- FOLLOWERS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS followers (
  follower_id       INTEGER NOT NULL,
  followed_id       INTEGER NOT NULL,

  PRIMARY KEY (follower_id, followed_id),

  created_by        INTEGER,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP,

  CONSTRAINT fk_follower_user FOREIGN KEY (follower_id) REFERENCES users(id),
  CONSTRAINT fk_followed_user FOREIGN KEY (followed_id) REFERENCES users(id),
  CONSTRAINT chk_follower_neq_followed CHECK (follower_id != followed_id)
);

-----------------------------------------------------------
-- BUDDIES TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS buddies (
  buddy_one_id      INTEGER NOT NULL,
  buddy_two_id      INTEGER NOT NULL,

  created_by        INTEGER,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deleted_at        TIMESTAMP,

  CONSTRAINT fk_buddy_one_user FOREIGN KEY (buddy_one_id) REFERENCES users(id),
  CONSTRAINT fk_buddy_two_user FOREIGN KEY (buddy_two_id) REFERENCES users(id),
  CONSTRAINT chk_one_id_neq_two_id CHECK (buddy_one_id != buddy_two_id);
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

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP,

  PRIMARY KEY (badge_id, user_id),

  CONSTRAINT fk_badge FOREIGN KEY (badge_id) REFERENCES badges(id),
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
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
  deleted_at        TIMESTAMP,

  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT chk_distance_geq_zero CHECK (distance >= 0),
  CONSTRAINT chk_height_diff_geq_zero CHECK (height_diff >= 0),
  CONSTRAINT chk_avg_speed_geq_zero CHECK (avg_speed >= 0),
  CONSTRAINT chk_min_speed_geq_zero CHECK (min_speed >= 0),
  CONSTRAINT chk_max_speed_geq_zero CHECK (max_speed >= 0),
  CONSTRAINT chk_min_leq_avg_leq_max_speed CHECK (min_speed <= avg_speed AND avg_speed <= max_speed),  -- Does accept nulls values
  CONSTRAINT chk_start_le_end_datetime CHECK (start_datetime < end_datetime)                           -- A session stays at least > 0 seconds
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

  PRIMARY KEY (id),

  CONSTRAINT chk_depth_geq_zero CHECK (tag_depth >= 0)
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
  deleted_at        TIMESTAMP,

  CONSTRAINT fk_owner_user FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT chk_challenges_dates CHECK (start_datetime < end_datetime),
  CONSTRAINT chk_capacity CHECK (
    (is_collective = FALSE AND capacity_max IS NULL) OR
    (is_collective = TRUE AND capacity_max IS NOT NULL AND capacity_max > 0)
  )
);

CREATE TABLE IF NOT EXISTS challenges_goals (
  id                SERIAL PRIMARY KEY,
  challenge_id      INTEGER NOT NULL,
  objective_type_id INTEGER NOT NULL,
  targeted_value    FLOAT NOT NULL,
  condition         TEXT NOT NULL DEFAULT 'greater_or_equal',

  UNIQUE (challenge_id, objective_type_id),

  CONSTRAINT fk_challenge_id FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
  CONSTRAINT fk_objective_type_id FOREIGN KEY (objective_type_id) REFERENCES objective_types_tags(id),
  CONSTRAINT chk_goal_condition CHECK (condition IN
    ('greater_than', 'greater_or_equal', 'less_than', 'less_or_equal', 'equal')
  )
);

-----------------------------------------------------------
-- CHALLENGE MEMBERS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS challenge_members (
  user_id           INTEGER NOT NULL,
  challenge_id      INTEGER NOT NULL,
  is_completed      BOOLEAN NOT NULL DEFAULT FALSE,
  is_ended          BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at      TIMESTAMP,

  PRIMARY KEY (user_id, challenge_id),

  CONSTRAINT fk_member_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_member_challenge FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE
);

-----------------------------------------------------------
-- INVITATIONS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS invitations (
  id                SERIAL PRIMARY KEY,
  inviter_id        INTEGER NOT NULL,
  invited_id        INTEGER NOT NULL,
  challenge_id      INTEGER NOT NULL,
  status            VARCHAR(50) NOT NULL,
  is_deleted        BOOLEAN NOT NULL DEFAULT FALSE,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP,

  CONSTRAINT fk_inviter_user FOREIGN KEY (inviter_id) REFERENCES users(id),
  CONSTRAINT fk_invited_user FOREIGN KEY (invited_id) REFERENCES users(id),
  CONSTRAINT fk_invitation_challenge FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE
);

-----------------------------------------------------------
-- DISPOSITIVES TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS dispositives (
  id                SERIAL PRIMARY KEY,
  user_id           INTEGER NOT NULL,
  name              VARCHAR(100) NOT NULL,
  brand             VARCHAR(100),
  model             VARCHAR(100),

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP,

  CONSTRAINT fk_dispositive_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS capabilities (
  id                SERIAL PRIMARY KEY,
  name              VARCHAR(100) NOT NULL,
  unit              VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS dispositives_capabilities (
  dispositive_id    INTEGER NOT NULL,
  capability_id     INTEGER NOT NULL,

  PRIMARY KEY (dispositive_id, capability_id),

  CONSTRAINT fk_dispositive FOREIGN KEY (dispositive_id) REFERENCES dispositives(id),
  CONSTRAINT fk_capability FOREIGN KEY (capability_id) REFERENCES capabilities(id)
);

-----------------------------------------------------------
-- LEVELS TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS levels (
  user_id                       INTEGER PRIMARY KEY,
  challenge_creation_level      INTEGER NOT NULL DEFAULT 0,
  challenge_done_level          INTEGER NOT NULL DEFAULT 0,
  session_done_level            INTEGER NOT NULL DEFAULT 0,
  invitation_level              INTEGER NOT NULL DEFAULT 0,

  CONSTRAINT fk_level_user FOREIGN KEY (user_id) REFERENCES users(id)
);
