build: ## build it
	docker-compose build
up: ## run it
	docker-compose up -d
	mutagen create --ignore .git --ignore vendor/cache --ignore tmp --ignore public -m two-way-resolved --label app=ai-integration . docker://ai_integration_web_1/ai_integration
down: ## un-run it
	docker-compose down
	mutagen terminate --label-selector app=ai-integration
exec: ## shell it
	docker-compose exec web /bin/bash
attach: ## attach it
	docker attach ai_integration_web_1
