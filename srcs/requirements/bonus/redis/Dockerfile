FROM alpine:3.21

RUN apk add --no-cache redis=7.2.11-r0

EXPOSE 6379

CMD ["redis-server", "--save", "", "--appendonly", "no", \
 "--maxmemory", "256mb", "--maxmemory-policy", "allkeys-lru", \
 "--protected-mode", "no"]