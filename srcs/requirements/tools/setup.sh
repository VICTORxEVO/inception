#! /bin/bash

set -e  # Exit on error

# Colors
readonly RED=$'\033[0;31m'
readonly GREEN=$'\033[0;32m'
readonly BOLD=$'\033[1m'
readonly RESET=$'\033[0m'

env_file="srcs/.env"

if [ ! $# -eq 1 ];
then
    echo "usage: setup.sh <env|check-env|secrets|check-secrets|data_dir>"
    exit 1
fi

if [ $# -eq 1 ] && [ "$1" == "env" ];
then
    if [ ! -s "${env_file}" ];
    then
        default_login="$(whoami)"
        default_domain="ysbai-jo.42.fr"

        cat > "${env_file}" <<- EOF
		LOGIN=${default_login}
		DOMAIN_NAME=${default_domain}

		# Database
		MYSQL_DATABASE=wordpress
		MYSQL_USER=wp_user

		# WordPress
		WP_URL=https://\${DOMAIN_NAME}
		WP_TITLE=wordpress
		WP_ADMIN_USER=imperor
		WP_ADMIN_EMAIL=imperor@proton.me
		WP_USER=salto7
		WP_USER_EMAIL=salto7@proton.me

		# FTP
		FTP_ADMIN_USER=${default_login}
		FTP_USER=salto7
		EOF

    fi
    exit 0
fi

if [ $# -eq 1 ] && [ "$1" == "check-env" ];
then
    if [ ! -s "${env_file}" ];
    then
        echo "${RED}${BOLD}✗ srcs/.env not found or empty. Run 'make env' first.${RESET}"
        exit 1
    fi
    echo "${GREEN}${BOLD}✓ .env file OK${RESET}"
    exit 0
fi

generate_password ()
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
if [ $# -eq 1 ] && [ "$1" == "secrets" ];
then
    SECRETS_DIR="./secrets"
    mkdir -p "${SECRETS_DIR}"
    create_password_file "${SECRETS_DIR}/db_root_password.txt"
    create_password_file "${SECRETS_DIR}/db_user_password.txt"
    create_password_file "${SECRETS_DIR}/wp_admin_password.txt"
    create_password_file "${SECRETS_DIR}/wp_user_password.txt"
    create_password_file "${SECRETS_DIR}/ftp_admin_password.txt"
    create_password_file "${SECRETS_DIR}/ftp_user_password.txt"
    create_password_file "${SECRETS_DIR}/portainer_admin_password.txt"
    exit 0
fi

if [ $# -eq 1 ] && [ "$1" == "check-secrets" ];
then
    SECRETS_DIR="./secrets"
    if [ ! -d "${SECRETS_DIR}" ];
    then
        echo "${RED}${BOLD}✗ secrets/ directory not found. Run 'make secrets' first.${RESET}"
        exit 1
    fi
    for f in \
        "${SECRETS_DIR}/db_root_password.txt" \
        "${SECRETS_DIR}/db_user_password.txt" \
        "${SECRETS_DIR}/wp_admin_password.txt" \
        "${SECRETS_DIR}/wp_user_password.txt" \
        "${SECRETS_DIR}/ftp_admin_password.txt" \
        "${SECRETS_DIR}/ftp_user_password.txt" \
        "${SECRETS_DIR}/portainer_admin_password.txt";
        do
            if [ ! -s "${f}" ];
            then
                echo "${RED}${BOLD}✗ ${f} is missing or empty. Run 'make secrets' first.${RESET}"
                exit 1
            fi
        done
    echo "${GREEN}${BOLD}✓ All secrets present${RESET}"
    exit 0
fi

if [ $# -eq 1 ] && [ "$1" == "data-dir" ];
then
    LOGIN="$(grep '^LOGIN=' "${env_file}" | cut -d '=' -f2)"
    mkdir -p "/home/${LOGIN}/data/db" "/home/${LOGIN}/data/wp"
fi


echo "✓ Setup complete !"



