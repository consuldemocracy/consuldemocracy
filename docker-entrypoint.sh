#!/bin/bash
set -e  # Exit immediately if a command exits with non-zero status

# Get the host user's UID and GID to match permissions with the host
USER_UID=$(stat -c %u /var/www/consul/Gemfile)
USER_GID=$(stat -c %g /var/www/consul/Gemfile)
export USER_UID
export USER_GID

# Change consul user UID/GID to match host user to avoid permission issues
# The || true prevents the script from failing if usermod/groupmod fails
usermod -u "$USER_UID" consul 2> /dev/null || true
groupmod -g "$USER_GID" consul 2> /dev/null || true
usermod -g "$USER_GID" consul 2> /dev/null || true

# Fix permissions for gems if BUNDLE_PATH is set
if [ -n "$BUNDLE_PATH" ]; then
  chown -R -h "$USER_UID" "$BUNDLE_PATH" 2>/dev/null || true
  chgrp -R -h "$USER_GID" "$BUNDLE_PATH" 2>/dev/null || true
fi

# Remove a potentially pre-existing server.pid to avoid "server already running" errors
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Wait for database to be ready before continuing
echo "Waiting for database..."
while ! pg_isready -h ${DB_HOST:-database} -p ${DB_PORT:-5432} -U ${DB_USERNAME:-postgres} >/dev/null 2>&1; do
  sleep 1
done
echo "Database is ready!"

# Only run database setup for the Rails server process
# This prevents multiple containers from trying to create the database simultaneously
if [[ "$1" == "bundle" && "$2" == "exec" && "$3" == "rails" && "$4" == "server" ]]; then
  echo "Setting up database if needed..."
  # db:prepare will create the database if it doesn't exist and run migrations
  sudo -EH -u consul bin/rails db:prepare
  
  # Optionally seed the database if needed (only for fresh installations)
  if [ "${SEED_DB:-false}" = "true" ]; then
    echo "Seeding the database..."
    sudo -EH -u consul bin/rails db:seed
  fi
fi

# Execute the container's main process as the consul user
# Uses sudo to switch to the consul user
exec /usr/bin/sudo -EH -u consul "$@"