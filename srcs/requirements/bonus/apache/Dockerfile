# Use the tiny Alpine image
FROM alpine:3.21

RUN apk add --no-cache apache2

COPY website_data/garlic-benefits.html /var/www/localhost/htdocs/index.html

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]