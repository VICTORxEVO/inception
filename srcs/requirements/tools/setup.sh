#! /bin/bash

set -e  # Exit on error

LOGIN="$(grep '^LOGIN=' ./srcs/.env | cut -d '=' -f2)"

# Create data directories
mkdir -p "/home/${LOGIN}/data/db" "/home/${LOGIN}/data/wp"

# Create secrets directory if it doesn't exist
SECRETS_DIR="./secrets"
mkdir -p "${SECRETS_DIR}"

# Function to generate secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Function to create password file safely
create_password_file() {
    local file="$1"
    
    if [ -f "${file}" ] && [ -s "${file}" ];
    then
        return 0
    fi
    
    echo "Generating password for ${file##*/}..."
    generate_password > "${file}"
    chmod 600 "${file}"
}

# Create all password files
create_password_file "${SECRETS_DIR}/db_root_password.txt"
create_password_file "${SECRETS_DIR}/db_user_password.txt"
create_password_file "${SECRETS_DIR}/wp_admin_password.txt"
create_password_file "${SECRETS_DIR}/wp_user_password.txt"
create_password_file "${SECRETS_DIR}/ftp_admin_password.txt"
create_password_file "${SECRETS_DIR}/ftp_user_password.txt"
create_password_file "${SECRETS_DIR}/portainer_admin_password.txt"

echo "✓ Setup complete - all directories and secrets ready"



