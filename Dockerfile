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