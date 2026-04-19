-----------------------------------------------------------
-- TAGS TABLE
-----------------------------------------------------------
CREATE TRIGGER trg_set_depth
BEFORE INSERT OR UPDATE ON tags
FOR EACH ROW
EXECUTE FUNCTION set_depth();
