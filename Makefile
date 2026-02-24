COMPOSE_FILE:=srcs/docker-compose.yml
LOGIN=$(shell grep '^LOGIN=' srcs/.env | cut -d '=' -f2)
DATA_PATH=/home/${LOGIN}/data

# Colors
GREEN:=\033[0;32m
BLUE:=\033[0;34m
CYAN:=\033[0;36m
YELLOW:=\033[1;33m
RED:=\033[0;31m
MAGENTA:=\033[0;35m
RESET:=\033[0m
BOLD:=\033[1m

all: up

check-env:
	@./srcs/requirements/tools/setup.sh check-env

check-secrets:
	@./srcs/requirements/tools/setup.sh check-secrets

env:
	@echo "$(CYAN)$(BOLD)📝 Creating .env file...$(RESET)"
	@sleep 0.8
	@./srcs/requirements/tools/setup.sh env
	@echo "$(GREEN)$(BOLD)✓ .env file ready$(RESET)"

secrets:
	@echo "$(CYAN)$(BOLD)📝 Creating sercet directory and files...$(RESET)"
	@sleep 0.8
	@./srcs/requirements/tools/setup.sh secrets
	@echo "$(GREEN)$(BOLD)✓ secret dir ready$(RESET)"

up: check-env check-secrets
	@echo "$(CYAN)$(BOLD)🚀 Setting up infrastructure...$(RESET)"
	@./srcs/requirements/tools/setup.sh data-dir
	@echo "$(GREEN)$(BOLD)🐳 Building and starting containers...$(RESET)"
	@sleep 1
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env up -d --build
	@echo "$(GREEN)$(BOLD)✓ Containers are up!$(RESET)"
	@echo "$(BLUE)📊 Showing logs (Ctrl+C to exit)...$(RESET)"
	@sleep 1
	@$(MAKE) --no-print-directory logs

down: check-env
	@echo "$(YELLOW)$(BOLD)🛑 Shutting down containers...$(RESET)"
	@sleep 1
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env down
	@echo "$(GREEN)$(BOLD)✓ All containers stopped$(RESET)"

delete:
	@echo "$(YELLOW)$(BOLD)🛑 deleting data directory...$(RESET)"
	@	@if [ -d "$(DATA_PATH)" ]; then sudo rm -rf $(DATA_PATH); fi
	@sleep 1
	@echo "$(GREEN)$(BOLD)✓ Data cleared$(RESET)"

ps: check-env
	@echo "$(CYAN)$(BOLD)📋 Container Status:$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env ps

logs: check-env
	@echo "$(BLUE)$(BOLD)📜 Following container logs...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env logs -f

stats: check-env
	@echo "$(MAGENTA)$(BOLD)📊 Container Resource Usage:$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env stats

clear: check-env clean delete
	@echo "$(RED)$(BOLD)🗑️  Removing all data...$(RESET)"
	@sleep 1
	@$(MAKE) --no-print-directory all

clean:
	@echo "$(RED)$(BOLD)🔥 Full cleanup - removing all Docker resources...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env down --volumes
	@docker system prune -f
	@docker volume prune -f
	@docker network prune -f
	@echo "$(GREEN)$(BOLD)✓ Full cleanup complete$(RESET)"



re: fclean all

.PHONY: all env check-env secrets check-secrets up down ps logs clean fclean re clear delete