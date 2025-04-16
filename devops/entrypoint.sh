#!/bin/sh
set -e  # Exit on error

# Initialize PostgreSQL if necessary
if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
    echo "Initializing PostgreSQL database..."
    su - postgres -c 'initdb -D /var/lib/postgresql/data'
fi

# Start PostgreSQL in the foreground
su - postgres -c 'postgres -D /var/lib/postgresql/data' &

# Wait for PostgreSQL to be fully ready
echo "Waiting for PostgreSQL to start..."
until pg_isready -h localhost -p 5432 -U postgres; do
    sleep 1
done

echo "PostgreSQL is ready. Starting NestJS..."
echo "Current directory: $(pwd)"
exec node dist/src/main.js
