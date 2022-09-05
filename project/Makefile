all:
	@docker compose -f srcs/docker-compose.yml build
	@docker compose -f srcs/docker-compose.yml up -d
down:
	@docker compose -f srcs/docker-compose.yml down
clean:
	@docker compose -f srcs/docker-compose.yml down
prune :
	@docker system prune -f --all
wordpress :
	@docker exec -it wordpress bash

nginx :
	@docker exec -it nginx bash
db :
	@docker exec -it mariadb bash
re : clean all
---
name = simple_nginx_html
all:
	@printf "Запуск конфигурации ${name}...\n"
	@docker-compose -f ./docker-compose.yml up -d

down:
	@printf "Остановка конфигурации ${name}...\n"
	@docker-compose -f ./docker-compose.yml down

re:
	@printf "Пересборка конфигурации ${name}...\n"
	@docker-compose -f ./docker-compose.yml up -d --build

clean: down
	@printf "Очистка конфигурации ${name}...\n"
	@docker system prune --all

fclean:
	@printf "Полная очистка всех конфигураций docker\n"
	@docker stop $$(docker ps -qa)
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --force

.PHONY: all re down clean fclean
