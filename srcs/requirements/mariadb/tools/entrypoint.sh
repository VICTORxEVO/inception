#!/bin/sh
set -e

DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"
DB_USER_PASS="$(cat /run/secrets/db_user_password)"

if [ ! -d /var/lib/mysql/mysql ];
then
  echo "Initializing database..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid="$!"

  echo "Waiting for mysqld..."
  until mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent; do
    sleep 1
  done

  mariadb --socket=/run/mysqld/mysqld.sock <<-EOSQL
    SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${DB_ROOT_PASS}');
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASS}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  kill "$pid"
  wait "$pid"
fi

echo "running command " "$@" "..."
exec "$@"