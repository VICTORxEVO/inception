FROM alpine:3.21

RUN apk add --no-cache \
    php84 \
    php84-session \
    php84-mysqli \
    php84-json \
    wget

WORKDIR /var/www/html

# get lastest adminer 5.4.1
RUN wget "https://www.adminer.org/static/download/5.4.1/adminer-5.4.1.php" \
    -O index.php && chmod 644 index.php

EXPOSE 8080

CMD ["php84", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]