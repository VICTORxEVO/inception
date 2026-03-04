FROM alpine:3.21

RUN apk add --no-cache \
    php84 \
    php84-session \
    php84-mysqli \
    php84-json \
    wget

WORKDIR /var/www/html

# lastest adminer 5.4.2
RUN wget "https://github.com/vrana/adminer/releases/download/v5.4.2/adminer-5.4.2-mysql.php" \
    -O index.php && chmod 644 index.php

EXPOSE 8080

CMD ["php84", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]