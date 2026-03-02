# Use the tiny Alpine image
FROM alpine:3.21

RUN apk add --no-cache apache2

COPY website_data/ /var/www/localhost/htdocs/

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]