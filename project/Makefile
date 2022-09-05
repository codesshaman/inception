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
