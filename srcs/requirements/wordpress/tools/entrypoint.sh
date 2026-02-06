#!/bin/sh
# exit in case of error
set -e

DB_PASS="$(cat /run/secrets/db_user_password)"
WP_ADMIN_PASS="$(cat /run/secrets/wp_admin_password)"
WP_USER_PASS="$(cat /run/secrets/wp_user_password)"

# Wait for DB
echo "Waiting for MariaDB to be ready..."
counter=0
max_tries=30

until mariadb -h mariadb \
  -u"${MYSQL_USER}" \
  -p"${DB_PASS}" \
  -e "SELECT 1;" \
  "${MYSQL_DATABASE}" >/dev/null 2>&1;
do
  counter=$((counter + 1))
  if [ $counter -gt $max_tries ]; then
    echo "Error: MariaDB not available after $max_tries attempts"
    exit 1
  fi
  echo "Attempt $counter/$max_tries: MariaDB not ready yet..."
  sleep 2
done
echo "MariaDB is ready!"

if [ ! -f wp-config.php ];
then
  echo "Downloading WordPress..."
  wp core download --allow-root

  echo "Linking to db..."
  wp config create --allow-root \
    --dbname="${MYSQL_DATABASE}" \
    --dbuser="${MYSQL_USER}" \
    --dbpass="${DB_PASS}" \
    --dbhost="mariadb:3306" \
    --skip-check

  echo "Installing WordPress..."
  wp core install --allow-root \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASS}" \
    --admin_email="${WP_ADMIN_EMAIL}"

  echo "Creating additional user..."
  wp user create --allow-root \
    "${WP_USER}" "${WP_USER_EMAIL}" \
    --user_pass="${WP_USER_PASS}" \
    --role=author
    
  # --- REDIS SETUP STARTS HERE ---
    
    # 3. Add Redis Host/Port to wp-config.php
  wp config set WP_REDIS_HOST redis --allow-root
  wp config set WP_REDIS_PORT 6379 --allow-root
  # This prevents the cache from being shared if you had multiple sites
  wp config set WP_CACHE_KEY_SALT "${DOMAIN_NAME}" --allow-root 

  # 4. Install the Plugin
  echo "installing redis plugin..."
  wp plugin install redis-cache --activate --allow-root
    
  # 5. Enable the actual Object Cache (This creates wp-content/object-cache.php)
   wp redis enable --allow-root
fi

# add redis (website cache)
# 1. Create the page only if it doesn't exist
if ! wp post list --post_type=page --name='garlic-benefits' --format=ids --allow-root | grep -q . ;
then
    
    wp post create /tmp/website_data/garlic-benefits.html \
        --post_type=page \
        --post_title='garlic benefits' \
        --post_name='garlic-benefits' \
        --post_status=publish \
        --allow-root

    # 2. Get the ID
    page_id=$(wp post list --post_type=page --name='garlic-benefits' --field=ID --allow-root)

    # 3. Set as Front Page
    wp option update show_on_front 'page' --allow-root
    wp option update page_on_front "$page_id" --allow-root
    
    echo "page active!"
fi

echo "runing command " "$@" "..."
exec "$@"