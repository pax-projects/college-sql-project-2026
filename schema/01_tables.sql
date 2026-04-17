-----------------------------------------------------------
-- USER TABLE
-----------------------------------------------------------
CREATE TABLE "user" (
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
