-----------------------------------------------------------
-- USER TABLE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS "user" (
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
-- USER BADGE
-----------------------------------------------------------
CREATE TABLE IF NOT EXISTS badge (
  id                SERIAL PRIMARY KEY,
  name              VARCHAR(50) NOT NULL,

  created_by        INTEGER NOT NULL,
  updated_by        INTEGER,
  deleted_by        INTEGER,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at        TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_badge (
  id                SERIAL PRIMARY KEY,
  badge_id          INTEGER NOT NULL,
  user_id           INTEGER NOT NULL,
  obtention_date    TIMESTAMP NOT NULL,
  UNIQUE (badge_id, user_id)
);


CREATE TABLE challenge (
    id                  SERIAL PRIMARY KEY,
    owner_id            INTEGER NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    title               VARCHAR(255) NOT NULL,
    description         TEXT,

    start_datetime      TIMESTAMP NOT NULL,
    end_datetime        TIMESTAMP NOT NULL,
    
    is_collective       BOOLEAN NOT NULL DEFAULT FALSE,
    capacity_max        INTEGER,
    
    created_by        INTEGER NOT NULL,
    updated_by        INTEGER,
    deleted_by        INTEGER,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at        TIMESTAMP,

    CONSTRAINT chk_challenge_dates CHECK (start_datetime < end_datetime),
    CONSTRAINT chk_capacity CHECK (
        (is_collective = FALSE AND capacity_max IS NULL) OR 
        (is_collective = TRUE AND capacity_max IS NOT NULL AND capacity_max > 0)
    )
);

CREATE TABLE objective_type (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    unit        VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS challenge_goal (
  id                  SERIAL PRIMARY KEY,
  challenge_id        INTEGER NOT NULL REFERENCES challenge(id) ON DELETE CASCADE,
  objective_type_id   INTEGER NOT NULL REFERENCES objective_type(id),
  targeted_value      FLOAT NOT NULL,
  condition           TEXT NOT NULL DEFAULT 'greater_or_equal' 
      CHECK (condition IN ('greater_than', 'greater_or_equal', 'less_than', 'less_or_equal', 'equal')),
  UNIQUE (challenge_id, objective_type_id)
);



-- will add challenge members later
