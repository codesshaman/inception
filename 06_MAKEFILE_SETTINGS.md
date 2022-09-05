# Создание Makefile

Перед сложным проектом потренируемся так же создавать ```Makefile```. Потренируемся на наших "кошечках" с готовой конфигурацией. На боевом проекте мы усложним мэйк, потому как контейнеров там будет больше. Ну а чтобы понять принципы, лучше всего начать от простого к сложному - написать мэйк к проекту из одного контейнера.

## Шаг 1. Узнаём имя нашего контейнера

Находясь в папке проекта выведем cat-ом 



Таким образом весь наш Makefile представляет из себя следующий код:

```
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

.PHONY	: all down re clean fclean
```