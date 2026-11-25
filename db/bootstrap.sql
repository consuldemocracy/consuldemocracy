-- Create the shared extensions schema.
CREATE SCHEMA IF NOT EXISTS shared_extensions;

-- Install required PostgreSQL extensions.
CREATE EXTENSION IF NOT EXISTS plpgsql
  WITH SCHEMA shared_extensions;

CREATE EXTENSION IF NOT EXISTS unaccent
  WITH SCHEMA shared_extensions;

CREATE EXTENSION IF NOT EXISTS pg_trgm
  WITH SCHEMA shared_extensions;

-- Allow the application user to use the schema.
GRANT USAGE, CREATE ON SCHEMA shared_extensions TO consul;
