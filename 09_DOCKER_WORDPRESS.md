# Создание контейнера wordpress

Итак, мы переходим к настройке wordpress.  Действуем всё так же: берём за основу последний alpine и накатываем на него нужный нам софт.

Но накатываем по-умному, указав актуальную на сегодня версию php. На момент создания гайда (2022) это php 8.1, если с 2022 года прошло много времени, нужно зайти на [официальный сайт php](https://www.php.net/ "официальный сайт php") и посмотреть, не вышла ли более новая версия.

Поэтому версию PHP я укажу в переменной - аргументе командной строки. Задаёт переменную инструкция ARG.

Сначала перечислим базовые компоненты: это php, на котором и работает наш wordpress, php-fpm для взаимодействия с nginx и php-mysqli для взаимодействия с mariadb:

```
FROM alpine:latest
ARG PHP_VERSION=8.1
RUN apk update && apk upgrade && apk add --no-cache \
	php${PHP_VERSION} \
	php${PHP_VERSION}-fpm \
	php${PHP_VERSION}-mysqli
```

Теперь обратимся к [документации wordpress](https://make.wordpress.org/hosting/handbook/server-environment/ "официальная документация wordpress") и посмотрим,что ещё нам понадобится.

Для полноценной работы нашего wordpress-а не поскупимся и загрузим все обязательные модули, опустив модули кэширования и дополнительные. Так же загрузим пакет wget, нужный для скачивания самого wordpress, и пакет unzip для разархивирования архива со скачанным wordpress:

```
FROM alpine:latest
ARG PHP_VERSION=8.1
RUN apk update && apk upgrade && apk add --no-cache \
	php${PHP_VERSION} \
	php${PHP_VERSION}-fpm \
	php${PHP_VERSION}-mysqli \
	php${PHP_VERSION}-json \
	php${PHP_VERSION}-curl \
	php${PHP_VERSION}-dom \
	php${PHP_VERSION}-exif \
	php${PHP_VERSION}-fileinfo \
	php${PHP_VERSION}-hash \
	php${PHP_VERSION}-imagick \
	php${PHP_VERSION}-mbstring \
	php${PHP_VERSION}-openssl \
	php${PHP_VERSION}-pcre \
	php${PHP_VERSION}-xml \
	php${PHP_VERSION}-zip \
	wget \
	&& rm -f /var/cache/apk/*
```

Последней командой мы очищаем кэш установленных модулей.

