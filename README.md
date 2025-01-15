# 使用Docker 备份 MongoDB 并上传至Minio

## 方案

1. 在 Docker 中安装 `mongodump`
2. 使用 mongodump 导出数据
3. 使用 tar 进行压缩
4. 使用 Minio Client 工具上传压缩包

## 实践

### 创建start.sh

```shell
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
```

### 创建Dockerfile

```dockerfile
FROM hengyun-docker.pkg.coding.net/enterprise-platform/docker-warehouse/ubuntu:22.04
RUN apt-get update && apt-get install -y curl vim

ENV MONGODB_HOST=localhost
ENV MONGODB_PORT=27017
ENV MONGODB_DB=database
ENV MONGODB_USERNAME=root
ENV MONGODB_PASSWORD=root
ENV MONGODB_AUTH=admin 
ENV BAIMA_PROJECT=project
# Minio 配置
ENV MINIO_ENDPOINT=http://localhost:9000
ENV MINIO_ACCESS_KEY=xxxxxxxxxx
ENV MINIO_SECRET_KEY=xxxxxxxxxx
ENV MINIO_BUCKET=bucket

COPY mongodump /usr/bin/
COPY mc /usr/bin/
COPY start.sh /

RUN chmod +x /usr/bin/mongodump
RUN chmod +x /usr/bin/mc
RUN chmod +x /start.sh

CMD ["/start.sh"]
```

### 构建Docker

```
docker build -t monogo-backup:0.0.0 .
```

### 使用备份镜像

```
docker run --rm -it -e MONGODB_HOST=localhost \
                    -e MONGODB_PORT=27017 \
                    -e MONGODB_DB=xxxxx \
                    -e MONGODB_USERNAME=xxxxx \
                    -e MONGODB_PASSWORD=xxxxx \
                    -e MONGODB_AUTH=xxxxx \
                    -e BAIMA_PROJECT=xxxxx \
                    -e MINIO_ENDPOINT=http://xxxxx:9000 \
                    -e MINIO_ACCESS_KEY=xxxxx \
                    -e MINIO_SECRET_KEY=xxxxx \
                    -e MINIO_BUCKET=xxxxx \
                    mongo-backup:0.0.0
```

