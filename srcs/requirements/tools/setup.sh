#! /bin/bash

set -e  # Exit on error

LOGIN="$(grep '^LOGIN=' ./srcs/.env | cut -d '=' -f2)"
env_file="srcs/.env"

mkdir -p "/home/${LOGIN}/data/db" "/home/${LOGIN}/data/wp"

if [ -f "$env_file" ];
then
    touch "$env_file"
fi

SECRETS_DIR="./secrets"
mkdir -p "${SECRETS_DIR}"

generate_password()
{
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

create_password_file()
{
    local file="$1"
    
    if [ -f "${file}" ] && [ -s "${file}" ];
    then
        return 0
    fi
    
    echo "Generating password for ${file##*/}..."
    generate_password > "${file}"
    chmod 600 "${file}"
}

create_password_file "${SECRETS_DIR}/db_root_password.txt"
create_password_file "${SECRETS_DIR}/db_user_password.txt"
create_password_file "${SECRETS_DIR}/wp_admin_password.txt"
create_password_file "${SECRETS_DIR}/wp_user_password.txt"
create_password_file "${SECRETS_DIR}/ftp_admin_password.txt"
create_password_file "${SECRETS_DIR}/ftp_user_password.txt"
create_password_file "${SECRETS_DIR}/portainer_admin_password.txt"

echo "✓ Setup complete - all directories and secrets ready"



