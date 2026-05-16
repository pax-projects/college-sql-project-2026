-- Fill followers table
DO $$
DECLARE
  i INTEGER;
  table_size INTEGER;
  u1 INTEGER;
  u2 INTEGER;
BEGIN
  SELECT COUNT(*) INTO table_size FROM users;

  FOR i IN 1..(table_size / 3) LOOP
    -- Select a random id
    SELECT id INTO u1
    FROM users
    ORDER BY random()
    LIMIT 1;

    -- Select a second random id
    SELECT id INTO u2
    FROM users
    WHERE id <> u1
    ORDER BY random()
    LIMIT 1;

    INSERT INTO followers (follower_id, followed_id)
    VALUES (u1, u2);

  END LOOP;
END;
$$;

-- Fill buddies table
DO $$
DECLARE
  i INTEGER;
  table_size INTEGER;
  u1 INTEGER;
  u2 INTEGER;
BEGIN
  SELECT COUNT(*) INTO table_size FROM followers;

  FOR i IN 1..(table_size / 3) LOOP
    -- Select a random id
    SELECT follower_id, followed_id INTO u1, u2
    FROM followers
    ORDER BY random()
    LIMIT 1;

    INSERT INTO followers (follower_id, followed_id)
    VALUES (u2, u1);

  END LOOP;
END;
$$;
