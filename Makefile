build: ## build it
	docker compose build
up: ## run it
	docker compose up -d
down: ## un-run it
	docker compose down
exec: ## shell it
	docker compose exec web /bin/bash
attach: ## attach it
	docker attach fams_tools_web_1
