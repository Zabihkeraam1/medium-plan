#!/bin/bash
set -e

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -U postgres; do
  echo "Waiting for PostgreSQL to start..."
  sleep 2
done

# Create application user and database
psql -v ON_ERROR_STOP=1 -U postgres <<-EOSQL
    CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';
    CREATE DATABASE mydb WITH OWNER myuser;
    GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
    
    \c mydb
    GRANT ALL PRIVILEGES ON SCHEMA public TO myuser;
    ALTER SCHEMA public OWNER TO myuser;
EOSQL

echo "Database initialization complete!"
