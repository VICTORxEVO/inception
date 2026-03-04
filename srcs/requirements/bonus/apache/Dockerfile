FROM alpine:3.21

RUN apk add --no-cache apache2 \
    && echo "ServerName localhost" >> /etc/apache2/httpd.conf

COPY website_data/ /var/www/localhost/htdocs/
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["httpd", "-D", "FOREGROUND"]