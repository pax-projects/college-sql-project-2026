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
RETURNS TRIGGER AS $$ -- FIXME: This was missing so not compiling
  DECLARE
    -- NOTE: Use complete names not abreviation (we're not payed per char lol (we are not paid at all... :( ))
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
          AND c.start_datetime <= NEW.debut
          AND c.end_datetime >= NEW.fin
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
                  goal.objective_type_id = (SELECT id FROM objective_type WHERE name = 'distance')
                  THEN NEW.distance
                WHEN
                  goal.objective_type_id = (SELECT id FROM objective_type WHERE name = 'elevation')
                  THEN NEW.height_difference
                  -- NOTE: That's cool mate !!!
                  -- so when we add a new objective_type we need to handle it
                  -- here
                ELSE 0
              END
            ) INTO achieved
            FROM session s
            WHERE s.user_id = NEW.user_id
              AND s.debut >= (SELECT start_datetime FROM challenges WHERE id = chal.challenge_id)
              AND s.fin   <= (SELECT end_datetime FROM challenges WHERE id = chal.challenge_id);

            IF (goal.condition = 'greater_or_equal' AND achieved < goal.targeted_value)   OR
               (goal.condition = 'greater_than'     AND achieved <= goal.targeted_value)  OR
               (goal.condition = 'less_or_equal'    AND achieved > goal.targeted_value)   OR
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

