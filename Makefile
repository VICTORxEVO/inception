COMPOSE_FILE=srcs/docker-compose.yml
# Extract only the LOGIN variable
LOGIN := $(shell grep '^LOGIN=' srcs/.env | cut -d '=' -f2)
DATA_PATH=/home/${LOGIN}/data

# Colors
GREEN=\033[0;32m
BLUE=\033[0;34m
CYAN=\033[0;36m
YELLOW=\033[1;33m
RED=\033[0;31m
MAGENTA=\033[0;35m
RESET=\033[0m
BOLD=\033[1m

all: up

up:
	@echo "$(CYAN)$(BOLD)🚀 Setting up infrastructure...$(RESET)"
	@./srcs/requirements/tools/setup.sh
	@echo "$(GREEN)$(BOLD)🐳 Building and starting containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env up -d --build
	@echo "$(GREEN)$(BOLD)✓ Containers are up!$(RESET)"
	@echo "$(BLUE)📊 Showing logs (Ctrl+C to exit)...$(RESET)"
	@$(MAKE) --no-print-directory logs

down:
	@echo "$(YELLOW)$(BOLD)🛑 Shutting down containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env down
	@echo "$(GREEN)$(BOLD)✓ All containers stopped$(RESET)"

ps:
	@echo "$(CYAN)$(BOLD)📋 Container Status:$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env ps

logs: 
	@echo "$(BLUE)$(BOLD)📜 Following container logs...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env logs -f

stats:
	@echo "$(MAGENTA)$(BOLD)📊 Container Resource Usage:$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env stats

clean:
	@echo "$(YELLOW)$(BOLD)🧹 Cleaning up containers and volumes...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) --env-file srcs/.env down --volumes
	@echo "$(GREEN)$(BOLD)✓ Cleanup complete$(RESET)"

clear: fclean
	@echo "$(RED)$(BOLD)🗑️  Removing all data...$(RESET)"
	@sudo rm -r $(DATA_PATH)/*
	@echo "$(GREEN)$(BOLD)✓ Data cleared$(RESET)"
	@$(MAKE) --no-print-directory all

fclean: clean
	@echo "$(RED)$(BOLD)🔥 Full cleanup - removing all Docker resources...$(RESET)"
	@docker system prune -af
	@docker volume prune -f
	@docker network prune -f
	@echo "$(GREEN)$(BOLD)✓ Full cleanup complete$(RESET)"

re: fclean all

.PHONY: all up down ps logs clean fclean re