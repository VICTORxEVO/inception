#!/bin/sh
set -e

# Set ServerName to the configured domain (or fallback to localhost)
DOMAIN="${DOMAIN_NAME:-localhost}"
sed -i "s/^ServerName .*/ServerName ${DOMAIN}/" /etc/apache2/httpd.conf

# Redirect logs to Docker stdout/stderr
ln -sf /dev/stdout /var/log/apache2/access.log
ln -sf /dev/stderr /var/log/apache2/error.log

echo "running command " "$@" "..."

exec "$@"
