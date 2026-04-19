-----------------------------------------------------------
-- TAGS TABLE
-----------------------------------------------------------
CREATE FUNCTION set_depth()
RETURNS TRIGGER AS $$
  DECLARE parent_depth INT;
  BEGIN
    IF NEW.parent_id IS NULL THEN
      NEW.tag_depth := 0;
    ELSE
      SELECT tag_depth INTO parent_depth
      FROM tags
      WHERE id = NEW.parent_id;

      NEW.tag_depth := parent_depth + 1;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;
