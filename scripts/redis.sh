#!/bin/bash
set -e

# Wait for Redis to start
until redis-cli -a "$REDIS_PASSWORD" ping > /dev/null 2>&1; do
  echo "Waiting for Redis to start..."
  sleep 1
done

echo "Redis is up and running."

# Create users with ACL
echo "Creating users with appropriate permissions..."

# Create admin user
redis-cli -a "$REDIS_PASSWORD" ACL SETUSER "$REDIS_ADMIN_USER" on ">" "$REDIS_ADMIN_PASSWORD" allkeys allcommands

# Create application user with restricted permissions
redis-cli -a "$REDIS_PASSWORD" ACL SETUSER "$REDIS_APP_USER" on ">" "$REDIS_APP_PASSWORD" ~app:* +@read +@write +@set +@string +@list +@hash +@stream +@sortedset +@pubsub -@admin -@dangerous

# Save ACL to file
redis-cli -a "$REDIS_PASSWORD" ACL SAVE

# Create sample data
echo "Creating sample data..."
redis-cli -a "$REDIS_APP_PASSWORD" -u "$REDIS_APP_USER" SET app:greeting "Hello from Redis!"
redis-cli -a "$REDIS_APP_PASSWORD" -u "$REDIS_APP_USER" LPUSH app:users "user1" "user2" "user3"
redis-cli -a "$REDIS_APP_PASSWORD" -u "$REDIS_APP_USER" HSET app:config platform "Docker" region "Cloud" initialized_at "$(date)"

echo "Redis initialization completed successfully!"