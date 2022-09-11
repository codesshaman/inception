# Создание контейнера wordpress

Итак, мы переходим к настройке wordpress.  Действуем всё так же: берём за основу последний alpine и накатываем на него нужный нам софт без кэширования.

А нужны нам будут следующие компоненты: php, на котором и работает наш wordpress, php-fpm для взаимодействия с nginx и php-mysqli для взаимодействия с mariadb:

```
FROM alpine:latest
RUN apk update && apk upgrade && apk add --no-cache \
	php8 \
	php8-fpm \
	php8-mysqli \
	wget \
	vim \
	gettext \
	&& rm -f /var/cache/apk/*
```

