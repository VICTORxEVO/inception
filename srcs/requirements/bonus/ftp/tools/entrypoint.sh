#!/bin/sh
set -e

: "${FTP_ADMIN_USER:?FTP_ADMIN_USER is required}"
: "${FTP_USER:?FTP_USER is required}"

if [ -f /run/secrets/ftp_admin_password ];
then
  FTP_ADMIN_PASS="$(cat /run/secrets/ftp_admin_password)"
else
  echo "ftp_admin_password secret is required"
  exit 1
fi

if [ -f /run/secrets/ftp_user_password ];
then
  FTP_USER_PASS="$(cat /run/secrets/ftp_user_password)"
else
  echo "ftp_user_password secret is required"
  exit 1
fi

echo "${FTP_USER}" >> "/etc/vsftpd.chroot_list"

addgroup -S wpfiles

mkdir -p /var/www/html/wp-content/uploads

#create admin user and regular user without password yet and assign them to group
adduser -D -h "/var/www/html" -G wpfiles "$FTP_ADMIN_USER"
adduser -D -h "/var/www/html/wp-content/uploads" -G wpfiles "$FTP_USER"

#give admin ownship to wordpress files so have all permitions
chown -R "$FTP_ADMIN_USER:wpfiles" /var/www/html
#give read/execute permition to wordpress folder for all users exept admin 
chmod -R 755 /var/www/html


chown -R "$FTP_ADMIN_USER:wpfiles" /var/www/html/wp-content/uploads
chmod -R 775 /var/www/html/wp-content/uploads


echo "$FTP_ADMIN_USER:$FTP_ADMIN_PASS" | chpasswd
echo "$FTP_USER:$FTP_USER_PASS" | chpasswd

# Handle shutdown signals properly
trap 'kill -TERM $PID' TERM INT

/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf &
PID=$!
wait $PID
trap - TERM INT
wait $PID