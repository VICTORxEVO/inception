#! /bin/bash

LOGIN="$(grep '^LOGIN=' ./srcs/.env | cut -d '=' -f2)"

mkdir -p "/home/${LOGIN}/data/db" "/home/${LOGIN}/data/wp"



