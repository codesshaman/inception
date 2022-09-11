# Создание контейнера wordpress

## Шаг 1. Настройка Dockerfile

Итак, мы переходим к настройке wordpress.  Действуем всё так же: берём за основу последний alpine и накатываем на него нужный нам софт.

Но накатываем по-умному, указав актуальную на сегодня версию php. На момент создания гайда (2022) это php 8, если с 2022 года прошло много времени, нужно зайти на [официальный сайт php](https://www.php.net/ "официальный сайт php") и посмотреть, не вышла ли более новая версия.

Поэтому версию PHP я укажу в переменной - аргументе командной строки. Задаёт переменную инструкция ARG.

Сначала перечислим базовые компоненты: это php, на котором и работает наш wordpress, php-fpm для взаимодействия с nginx и php-mysqli для взаимодействия с mariadb:

```
FROM alpine:latest
ARG PHP_VERSION=8
RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysqli
```

Теперь обратимся к [документации wordpress](https://make.wordpress.org/hosting/handbook/server-environment/ "официальная документация wordpress") и посмотрим,что ещё нам понадобится.

Для полноценной работы нашего wordpress-а не поскупимся и загрузим все обязательные модули, опустив модули кэширования и дополнительные. Так же загрузим пакет wget, нужный для скачивания самого wordpress, и пакет unzip для разархивирования архива со скачанным wordpress:

```
FROM alpine:latest
ARG PHP_VERSION=8
RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    wget \
	unzip \
    && rm -f /var/cache/apk/*
```

Последней командой мы очищаем кэш установленных модулей.

Далее нам надо скачать wordpress и разархивировать его по пути /var/www. Для удобства сделаем этот путь рабочим командой WORKDIR:

```
FROM alpine:latest
ARG PHP_VERSION=8
RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    wget \
	unzip \
    && rm -f /var/cache/apk/*
WORKDIR /var/www
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    cp -rf wordpress/* . && \
    rm -rf wordpress latest.zip
```

В последней инструкции RUN мы загрузили wget-ом последнюю версию wordpress, разархивировали её и удалили все исходные файлы.


## Шаг 2. Конфигурация docker-compose

Теперь добавим в наш docker-compose секцию с wordpress.

Для начала пропишем 

```
    wordpress:
        depends_on:
            - mariadb
        image: wordpress:inc
        volumes:
            - ~/data/wp:/var/www/wordpress
        restart: always
        environment:
            WP_LOGIN: "${WP_LOGIN}"
            WP_PASS: "${WP_PASS}"
            WPU_1LOGIN: "${WPU_1LOGIN}"
            WPU_1PASS: "${WPU_1PASS}"
            MARIA_LOGIN: "${MARIA_LOGIN}"
            MARIA_PASS: "${MARIA_PASS}"
        ports:
            - "9000:9000"
        build:
            context: ./requirements/wordpress
            dockerfile: Dockerfile
        networks:
            vpcbr:
        env_file: .env
```



## Шаг 3. Конфигурация wordpress

Напишем тот самый конфиг start.sh для конфигурации wordpress:

```
#!/bin/sh
sleep 1;
if  [ ! -f /var/www/wordpress/wp-config.php ]; then 
    
    wp core --allow-root download --locale=ru_RU --force 
    sleep 2;
    while  [ ! -f /var/www/wordpress/wp-config.php ]; do   
        wp core config --allow-root --dbname=wordpress --dbuser=$MARIA_LOGIN --dbpass=$MARIA_PASS --dbhost=mariadb:3306
    done 
    wp core install --allow-root --url='lusehair.42.fr' --title='WordPress for Inception' --admin_user=$WP_LOGIN --admin_password=$WP_PASS  --admin_email="admin@admin.fr" --path='/var/www/wordpress';
    wp  user create --allow-root $WPU_1LOGIN user2@user.com --user_pass=$WPU_1PASS --role=author
    wp theme install --allow-root dark-mode --activate     
fi 
php-fpm8 --nodaemonize
```

