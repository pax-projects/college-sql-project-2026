-----------------------------------------------------------
-- TAGS TABLE
-----------------------------------------------------------
CREATE TRIGGER trg_set_depth
  BEFORE INSERT OR UPDATE ON sports_categories_tags
  FOR EACH ROW
  EXECUTE FUNCTION set_depth();

CREATE OR REPLACE TRIGGER check_challenges_completion 
  AFTER INSERT ON sessions
  FOR EACH ROW
  EXECUTE FUNCTION check_challenges_completion();
