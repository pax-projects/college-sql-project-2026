-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION add_vectors_on_new_user()
RETURNS TRIGGER AS $$
  BEGIN
    INSERT INTO vectors (entity_type, entity_id, category_id)
    SELECT
      'user',
      NEW.id,
      id
    FROM sports_categories_tags;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------
-- SPORTS CATEGORY TAGS TABLE
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION add_vector_on_new_sport_category()
RETURNS TRIGGER AS $$
  BEGIN
    INSERT INTO vectors (entity_type, entity_id, category_id)
    SELECT
      'user',
      id,
      NEW.id
    FROM users;

    INSERT INTO vectors (entity_type, entity_id, category_id)
    SELECT
      'challenge',
      id,
      NEW.id
    FROM challenges;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------
-- FOLLOWERS TABLE
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION move_to_buddies_if_reciprocal_followers()
RETURNS TRIGGER AS $$
  BEGIN
    IF EXISTS (
      SELECT 1
      FROM followers
      WHERE
        follower_id = NEW.followed_id AND
        followed_id = NEW.follower_id AND
        deleted_at IS NULL
    ) THEN
      -- We delete the follower row
      DELETE FROM followers
      WHERE
        follower_id = NEW.followed_id AND
        followed_id = NEW.follower_id AND
        deleted_at IS NULL;

      -- We add the row to the buddies table
      INSERT INTO buddies (buddy_one_id, buddy_two_id)
      VALUES (NEW.follower_id, NEW.followed_id);

      RETURN NULL;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------
-- TAGS TABLE
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION set_depth()
RETURNS TRIGGER AS $$
  DECLARE
    parent_depth INT;

  BEGIN
    IF NEW.parent_id IS NULL THEN
      NEW.tag_depth := 0;
    ELSE
      SELECT tag_depth INTO parent_depth
      FROM sports_categories_tags
      WHERE id = NEW.parent_id;

      NEW.tag_depth := parent_depth + 1;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------
-- CHALLENGE TABLE
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION check_challenges_completion()
RETURNS TRIGGER AS $$
  DECLARE
    chal record;
    goal record;
    achieved float;
    all_goals_met boolean;
  BEGIN
    FOR chal IN
        SELECT cm.challenge_id, c.end_datetime, c.is_collective
        FROM challenge_members cm
        JOIN challenges c ON c.id = cm.challenge_id
        WHERE cm.user_id = NEW.user_id
          AND cm.is_ended = FALSE
          AND cm.is_completed = FALSE
          AND c.start_datetime <= NEW.start_datetime
          AND c.end_datetime >= NEW.end_datetime
    LOOP
        all_goals_met := TRUE;

        FOR goal IN
            SELECT objective_type_id, targeted_value, condition
            FROM challenges_goals
            WHERE challenge_id = chal.challenge_id
        LOOP
            SELECT SUM(
              CASE
                WHEN
                  goal.objective_type_id = (SELECT id FROM objective_types_tags WHERE name = 'distance')
                  THEN NEW.distance
                WHEN
                  goal.objective_type_id = (SELECT id FROM objective_types_tags WHERE name = 'elevation')
                  THEN NEW.height_diff
                  -- NOTE: That's cool mate !!!
                  -- so when we add a new objective_type we need to handle it
                  -- here
                ELSE 0
              END
            ) INTO achieved
            FROM sessions s
            WHERE s.user_id = NEW.user_id
              AND s.start_datetime >= (SELECT start_datetime FROM challenges WHERE id = chal.challenge_id)
              AND s.end_datetime   <= (SELECT end_datetime FROM challenges WHERE id = chal.challenge_id);

            IF (goal.condition = 'greater_or_equal' AND achieved < goal.targeted_value)   OR
               (goal.condition = 'greater_than'     AND achieved <= goal.targeted_value)  OR
               (goal.condition = 'less_or_equal'    AND achieved > goal.targeted_value)   OR
               (goal.condition = 'less_than'        AND achieved >= goal.targeted_value)  OR
               (goal.condition = 'equal'            AND achieved <> goal.targeted_value)
            THEN
                all_goals_met := FALSE;
                EXIT;
            END IF;
        END LOOP;

        IF all_goals_met THEN
            UPDATE challenge_members
            SET is_completed = TRUE,
                completed_at = CURRENT_TIMESTAMP,
                is_ended = TRUE
            WHERE user_id = NEW.user_id
              AND challenge_id = chal.challenge_id;

        END IF;
      END LOOP;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_vectors_on_new_challenge()
RETURNS TRIGGER AS $$
  BEGIN
    INSERT INTO vectors (entity_type, entity_id, category_id)
    SELECT
      'challenge',
      NEW.id,
      id
    FROM sports_categories_tags;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------
-- SOFTMAX Calculus
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_vector_softmax(
  p_owner_id INTEGER,
  p_entity_type TEXT
)
RETURNS VOID AS $$
  DECLARE
    temperature CONSTANT FLOAT := 1.0;
  BEGIN
    UPDATE vectors v
    SET value = s.final_value
    FROM (
      WITH softmaxed AS (
        SELECT
          category_id,
          2 * (
            EXP(value / temperature) /
            SUM(EXP(value / temperature)) OVER ()
          ) - 1 AS new_value
        FROM vectors
        WHERE entity_type = p_entity_type
          AND entity_id = p_owner_id
      ),

      centered AS (
        SELECT
          category_id,
          new_value - (SELECT AVG(new_value) FROM softmaxed) AS centered_value
        FROM softmaxed
      ),

      norm AS (
        SELECT
          SQRT(SUM(POWER(centered_value, 2))) AS n
        FROM centered
      )

      SELECT
        category_id,
        centered_value / COALESCE((SELECT n FROM norm), 1) AS final_value
      FROM centered
    ) s
    WHERE
      v.entity_type = p_entity_type
      AND v.entity_id = p_owner_id
      AND v.category_id = s.category_id;
  END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------
-- WEEKLY CHALLENGE LIMIT
-----------------------------------------------------------
CREATE OR REPLACE FUNCTION enforce_weekly_challenge_limit()
RETURNS TRIGGER AS $$
  DECLARE
    week_start DATE;
    cnt INTEGER;
  BEGIN
    SELECT date_trunc('week', start_datetime)::date INTO week_start
    FROM challenges
    WHERE id = NEW.challenge_id;

    SELECT COUNT(*) INTO cnt
    FROM challenge_members cm
    JOIN challenges c ON c.id = cm.challenge_id
    WHERE cm.user_id = NEW.user_id
      AND date_trunc('week', c.start_datetime)::date = week_start;

    IF cnt >= 3 THEN
      RAISE EXCEPTION
        'Weekly limit reached: user % already in 3 challenges for week %',
        NEW.user_id, week_start;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;
