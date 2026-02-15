#!/usr/bin/env bash

DATA_VOLUME_NAME="pgdata"
IMAGE_REGISTRY_NAME="socraticDevBlog"
IMAGE_NAME="postgresql"
IMAGE_TAG="16v4"
CONTAINER_NAME="my_pgsql_cron_enabled_container"
DB_NAME="postgres"
DB_USERNAME="postgres"
DB_PASSWORD="strongpassword"
EXPOSED_PORT="5432"
SQL_SETUP_SCRIPT="setup_database.sql"

echo "Build the Docker image"

docker build -t $IMAGE_REGISTRY_NAME/$IMAGE_NAME:$IMAGE_TAG .

echo "Run the PostgreSQL container with cron plugin enabled"

docker volume create $DATA_VOLUME_NAME

docker run -d \
  --name $CONTAINER_NAME \
  -v $DATA_VOLUME_NAME:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=$DB_PASSWORD \
  -p $EXPOSED_PORT:5432 \
  -d \
  $IMAGE_REGISTRY_NAME/$IMAGE_NAME:$IMAGE_TAG \
  postgres -c shared_preload_libraries=pg_cron -c cron.database_name=$DB_NAME

echo "Check if the container is running and output logs"
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Container $CONTAINER_NAME is running."
    echo "Logs for the container:";
    docker logs $CONTAINER_NAME;
else
    echo "Container is not running."
    exit 1
fi

echo "Wait for PostgreSQL to be ready"
sleep 10

echo "setup database with cache and cron mechanism"
docker cp "$(pwd)/$SQL_SETUP_SCRIPT" $CONTAINER_NAME:/tmp/$SQL_SETUP_SCRIPT
docker exec -i $CONTAINER_NAME psql -U $DB_USERNAME -d $DB_NAME -f /tmp/$SQL_SETUP_SCRIPT
