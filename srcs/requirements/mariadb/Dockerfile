FROM alpine:3.21

RUN apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

RUN rm -f /etc/my.cnf.d/*

COPY conf/50-server.cnf /etc/my.cnf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

# use --console to attach to terminal and run in fourground
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mariadbd", "--user=mysql", "--console"]