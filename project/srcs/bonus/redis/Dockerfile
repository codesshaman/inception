FROM alpine:3.16

RUN apk update && apk upgrade && \
    apk add --no-cache redis && \
    mkdir /data && \
    chown -R redis:redis /data && \
    sed -i "s|bind 127.0.0.1|#bind 127.0.0.1|g" /etc/redis.conf && \
    sed -i "s|# maxmemory 10mb|maxmemory 2mb|g" /etc/redis.conf && \
    sed -i "s|# maxmemory-policy noevicrion|maxmemory-policy allkeys-lru|g" \
    /etc/redis.conf

EXPOSE 6379

CMD [ "redis-server" , "/etc/redis.conf" ]