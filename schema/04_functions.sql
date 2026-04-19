create or replace function check_challenge_completion()
declare
    chal record;
    goal record;
    achieved float;
    all_goals_met boolean;
begin

    for chal in 
        select cm.challenge_id, c.end_datetime, c.is_collective
        from challenge_members cm
        join challenge c ON c.id = cm.challenge_id
        where cm.user_id = NEW.user_id 
          AND cm.is_ended = FALSE
          AND cm.is_completed = FALSE
          AND c.start_datetime <= NEW.debut 
          AND c.end_datetime >= NEW.fin
    loop
        all_goals_met := TRUE;

        for goal in 
            select objective_type_id, targeted_value, condition
            from challenge_goal 
            where challenge_id = chal.challenge_id
        loop
            select SUM(
              case 
                when goal.objective_type_id = (SELECT id FROM objective_type WHERE name = 'distance') THEN NEW.distance
                when goal.objective_type_id = (SELECT id FROM objective_type WHERE name = 'elevation') THEN NEW.height_difference
                  -- so when we add a new objective_type we need to handle it
                  -- here
                else 0 
              end
            ) into achieved
            from session s
            where s.user_id = NEW.user_id
              and s.debut >= (SELECT start_datetime FROM challenge WHERE id = chal.challenge_id)
              and s.fin   <= (SELECT end_datetime FROM challenge WHERE id = chal.challenge_id);

            if (goal.condition = 'greater_or_equal' AND achieved < goal.targeted_value) OR
               (goal.condition = 'greater_than'     AND achieved <= goal.targeted_value) OR
               (goal.condition = 'less_or_equal'    AND achieved > goal.targeted_value) OR
            then
                all_goals_met := FALSE;
                EXIT;
            end if;
        end loop;

        if all_goals_met then
            UPDATE challenge_members 
            SET is_completed = TRUE,
                completed_at = CURRENT_TIMESTAMP,
                is_ended = TRUE
            WHERE user_id = NEW.user_id 
              AND challenge_id = chal.challenge_id;

        end if;
      end loop;

    return NEW;
end;
