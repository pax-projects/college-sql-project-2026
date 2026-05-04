DO $$
BEGIN
  IF NOT EXISTS (
    SELECT FROM pg_roles WHERE rolname = 'admin_user'
  ) THEN
    CREATE ROLE admin_user;
  END IF;
END
$$;

ALTER ROLE admin_user BYPASSRLS;
