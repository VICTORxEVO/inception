FROM alpine:3.21

RUN apk add --no-cache libc6-compat curl

RUN curl -L https://github.com/portainer/portainer/releases/download/2.39.0/portainer-2.39.0-linux-amd64.tar.gz -o portainer.tar.gz \
    && tar -xzf portainer.tar.gz -C /opt \
    && rm portainer.tar.gz

WORKDIR /opt/portainer

EXPOSE 9443 9000

# Connect to Docker via Unix socket and set admin password from secret file
ENTRYPOINT ["/opt/portainer/portainer"]
CMD ["--host", "unix:///var/run/docker.sock", "--admin-password-file", "/run/secrets/portainer_admin_password"]