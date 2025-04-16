#!/bin/bash
set -e

# Wait for Cassandra to be ready
until cqlsh -u cassandra -p cassandra -e "describe keyspaces" > /dev/null 2>&1; do
  echo "Waiting for Cassandra to start..."
  sleep 5
done

echo "Cassandra is up and running."

# Create admin user
echo "Creating admin superuser..."
cqlsh -u cassandra -p cassandra << EOF
CREATE ROLE IF NOT EXISTS $CASSANDRA_ADMIN_USER WITH PASSWORD = '$CASSANDRA_ADMIN_PASSWORD' AND SUPERUSER = true AND LOGIN = true;
ALTER ROLE cassandra WITH PASSWORD = 'cassandra_new_password' AND SUPERUSER = true;
EOF

# Create application user and keyspace
echo "Creating application keyspace and user..."
cqlsh -u $CASSANDRA_ADMIN_USER -p $CASSANDRA_ADMIN_PASSWORD << EOF
CREATE KEYSPACE IF NOT EXISTS $CASSANDRA_KEYSPACE 
WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};

CREATE ROLE IF NOT EXISTS $CASSANDRA_APP_USER 
WITH PASSWORD = '$CASSANDRA_APP_PASSWORD' AND SUPERUSER = false AND LOGIN = true;

GRANT ALL PERMISSIONS ON KEYSPACE $CASSANDRA_KEYSPACE TO $CASSANDRA_APP_USER;
EOF

echo "Database initialization completed successfully!"