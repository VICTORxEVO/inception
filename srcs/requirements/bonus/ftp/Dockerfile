FROM alpine:3.21

RUN apk add --no-cache vsftpd

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]