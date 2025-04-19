# #!/bin/sh

# # Wait for PostgreSQL to start
# until pg_isready -h localhost -p 5432 -U postgres; do
#   echo "Waiting for PostgreSQL to start..."
#   sleep 1
# done

# # Create database and user
# psql -U postgres -c "CREATE DATABASE mydb;"
# psql -U postgres -c "CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';"
# # psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;"
# psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;"
# psql -U postgres -d mydb -c "GRANT USAGE, CREATE ON SCHEMA public TO myuser;"
# psql -U postgres -d mydb -c "ALTER SCHEMA public OWNER TO myuser;"


#!/bin/bash
set -e

# Wait for PostgreSQL
until pg_isready -h postgres -U postgres; do
  sleep 1
done

# Create user and database
psql -v ON_ERROR_STOP=1 -h postgres -U postgres <<-EOSQL
  CREATE USER myuser WITH ENCRYPTED PASSWORD 'mypassword';
  CREATE DATABASE mydb WITH OWNER myuser;
  GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
  \c mydb
  GRANT ALL PRIVILEGES ON SCHEMA public TO myuser;
  ALTER SCHEMA public OWNER TO myuser;
EOSQL
