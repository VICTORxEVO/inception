FROM alpine:3.21

RUN apk add --no-cache nginx openssl gettext

# Create self-signed cert if none is mounted (for dev); replace with real certs as needed
RUN mkdir -p /etc/nginx/certs /var/www/html /run/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

# Minimal index to confirm proxy works
RUN echo "<h1>NGINX up</h1>" > /var/www/html/index.html

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]