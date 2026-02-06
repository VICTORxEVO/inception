#! /bin/bash

LOGIN="$(grep '^LOGIN=' ./srcs/.env | cut -d '=' -f2)"

mkdir -p "/home/${LOGIN}/data/db" "/home/${LOGIN}/data/wp" "/home/${LOGIN}/data/nginx_logs" "/home/${LOGIN}/data/fail2ban"



