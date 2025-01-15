#!/bin/bash

# show mongo parameters
echo "This is mongodb backup"
echo "MONGODB_HOST: "${MONGODB_HOST}
echo "MONGODB_PORT: "${MONGODB_PORT}
echo "MONGODB_DB: "${MONGODB_DB}
echo "MONGODB_USERNAME: "${MONGODB_USERNAME}
echo "MONGODB_PASSWORD: ***********"
echo "BAIMA_PROJECT: "${BAIMA_PROJECT}
# show minio parameters
echo "MINIO_ENDPOINT: "${MINIO_ENDPOINT}
echo "MINIO_ACCESS_KEY: "${MINIO_ACCESS_KEY}
echo "MINIO_SECRET_KEY: ***********"
echo "MINIO_BUCKET: "${MINIO_BUCKET}

# Get current time
NOW_TIME=$(date +"%Y%m%d%H%M%S")

SOURCE_DIR="/bak/${NOW_TIME}"
BACKUP_FILE="$BAIMA_PROJECT-${NOW_TIME}.tar.gz"
echo "SOURCE_DIR: $SOURCE_DIR"
echo "BACKUP_FILE: $BACKUP_FILE"

echo "start backup $MONGODB_DB ..."

# start the application
echo "mongodump --host ${MONGODB_HOST} --port ${MONGODB_PORT} --db ${MONGODB_DB} --username ${MONGODB_USERNAME} --password ${MONGODB_PASSWORD} --out ${SOURCE_DIR}"
mongodump --host ${MONGODB_HOST} --port ${MONGODB_PORT} --db ${MONGODB_DB} --username ${MONGODB_USERNAME} --password ${MONGODB_PASSWORD} --out ${SOURCE_DIR} --authenticationDatabase ${MONGODB_AUTH}
# restore the application

# Compress backup directory

echo "Start compressing directory: ${SOURCE_DIR}"
tar -czvf "$BACKUP_FILE" "${SOURCE_DIR}"
if [ $? -eq 0 ]; then
    echo "Directory compression completed, compressed file: $BACKUP_FILE"
else
    echo "Directory compression failed, exiting script"
    exit 1
fi

echo "Start uploading file to Minio server: $MINIO_ENDPOINT"
mc alias set mongo-backup $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
mc cp $BACKUP_FILE mongo-backup/$MINIO_BUCKET/$BAIMA_PROJECT/

if [ $? -eq 0 ]; then
    echo "File upload successful"
else
    echo "File upload failed"
fi