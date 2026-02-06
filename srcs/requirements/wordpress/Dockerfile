FROM alpine:3.21

ENV PHP_VER=84
RUN apk add --no-cache \
    php${PHP_VER} \
    php${PHP_VER}-cli \
    php${PHP_VER}-fpm \
    php${PHP_VER}-mysqli \
    php${PHP_VER}-json \
    php${PHP_VER}-openssl \
    php${PHP_VER}-curl \
    php${PHP_VER}-zip \
    php${PHP_VER}-phar \
    php${PHP_VER}-mbstring \
    php${PHP_VER}-xml \
    php${PHP_VER}-dom \
    php${PHP_VER}-session \
    php${PHP_VER}-pecl-redis \
    php${PHP_VER}-tokenizer \
    php${PHP_VER}-ctype \
    curl less mariadb-client

# Ensure wp-cli can find php in PATH
RUN ln -sf /usr/bin/php${PHP_VER} /usr/bin/php


# Configure php-fpm to listen on 0.0.0.0:9000
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php${PHP_VER}/php-fpm.d/www.conf \
 && sed -i 's|^;clear_env = no|clear_env = no|' /etc/php${PHP_VER}/php-fpm.d/www.conf

 # Increase memory limit for PHP-FPM
RUN sed -i 's/memory_limit = .*/memory_limit = 512M/' /etc/php${PHP_VER}/php.ini

# Install wp-cli
RUN curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o \
 /usr/local/bin/wp \
 && chmod +x /usr/local/bin/wp

WORKDIR /var/www/html
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY website_data /tmp/website_data/

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sh", "-c", "exec php-fpm${PHP_VER} -F"]