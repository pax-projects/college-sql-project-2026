-----------------------------------------------------------
-- USERS TABLE
-----------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_add_vectors_to_users_vectors
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION add_vectors_on_new_user();

-----------------------------------------------------------
-- CHALLENGE TABLE
-----------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_add_vectors_to_challenges_vectors
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION add_vectors_on_new_challenge();

-----------------------------------------------------------
-- SPORTS CATEGORY TAGS TABLE
-----------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_add_vector_on_new_sport_category
  AFTER INSERT ON sports_categories_tags
  FOR EACH ROW
  EXECUTE FUNCTION add_vector_on_new_sport_category();

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
