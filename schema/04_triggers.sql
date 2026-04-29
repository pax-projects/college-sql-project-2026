-----------------------------------------------------------
-- FOLLOWERS TABLE
-----------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_move_followers_to_buddy
  BEFORE INSERT OR UPDATE ON followers
  FOR EACH ROW
  EXECUTE FUNCTION move_to_buddies_if_reciprocal_followers();

-----------------------------------------------------------
-- TAGS TABLE
-----------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_set_depth
  BEFORE INSERT OR UPDATE ON sports_categories_tags 
  FOR EACH ROW
  EXECUTE FUNCTION set_depth();

CREATE OR REPLACE TRIGGER check_challenges_completion 
  AFTER INSERT ON sessions
  FOR EACH ROW
  EXECUTE FUNCTION check_challenges_completion();
