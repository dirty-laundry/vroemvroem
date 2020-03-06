#
# For more information on some of the magic targets, variables and flags used, see:
#  - [1] https://www.gnu.org/software/make/manual/html_node/Special-Targets.html
#  - [2] https://www.gnu.org/software/make/manual/html_node/Secondary-Expansion.html
#  - [3] https://www.gnu.org/software/make/manual/html_node/Suffix-Rules.html
#  - [4] https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
#  - [5] https://www.gnu.org/software/make/manual/html_node/Special-Variables.html
#  - [6] https://www.gnu.org/software/make/manual/html_node/Choosing-the-Shell.html
#

# Ensure (intermediate) targets are deleted when an error occurred executing a recipe, see [1]
.DELETE_ON_ERROR:

# Enable a second expansion of the prerequisites, see [2]
.SECONDEXPANSION:

# Disable built-in implicit rules and variables, see [3, 4]
.SUFFIXES:
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Disable printing of directory changes, see [4]
MAKEFLAGS += --no-print-directory

# Warn about undefined variables -- useful during development of makefiles, see [4]
MAKEFLAGS += --warn-undefined-variables

# Show an auto-generated help if no target is provided, see [5]
.DEFAULT_GOAL := help

# Default shell, see [6]
SHELL := /bin/bash

help:
	@echo
	@printf "%-20s %s\n" Target Description
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo

include Makefile.vars
include make/traefik.mk

#
# Docker-Compose Services & Containers
#

.PHONY: build
build: ## build containers
	docker-compose --project-name $(PROJECT) build --parallel --pull

.PHONY: fg
fg: traefik
fg: ## launch the docker-compose setup (foreground)
	docker-compose --project-name $(PROJECT) up --remove-orphans

.PHONY: up
up: traefik
up: ## launch the docker-compose setup (background)
	docker-compose --project-name $(PROJECT) up --remove-orphans --detach

.PHONY: down
down: ## terminate the docker-compose setup
	-docker-compose --project-name $(PROJECT) down --remove-orphans

.PHONY: logs
logs: ## show logs
	docker-compose --project-name $(PROJECT) logs

.PHONY: tail
tail: ## tail logs
	docker-compose --project-name $(PROJECT) logs --follow

.PHONY: shell
shell: ## spawn a shell inside a php-fpm container
	docker-compose --project-name $(PROJECT) run --rm -e APP_ENV --user $(DOCKER_USER) --no-deps composer sh
