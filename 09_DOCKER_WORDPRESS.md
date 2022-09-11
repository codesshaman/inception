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
CMD ["/usr/sbin/php-fpm8", "-F"]
```

В последней инструкции RUN мы загрузили wget-ом последнюю версию wordpress, разархивировали её и удалили все исходные файлы.

CMD же запускает наш установленный php-fpm (внимание: версия должна соответствовать установленной!)

## Шаг 2. Конфигурация docker-compose

Теперь добавим в наш docker-compose секцию с wordpress.

Для начала пропишем следующее:

```
  wordpress:
    build:
      context: .
      dockerfile: requirements/wordpress/Dockerfile
    depends_on:
      - mariadb
    restart: unless-stopped
```

Директива depends_on означает, что wordpress зависит от mariadb и не запустится, пока контейнер с базой данных не соберётся. Самым "шустрым" из наших контейнеров будет nginx - ввиду малого веса он соберётся и запустится первым. А вот база и CMS собираются примерно равное время, и чтобы не случилась, что wordpress начинает устанавливаться на ещё не развёрнутую базу потребуется указать эту зависимость.

Далее укажем директорию, в которой развернётся наш wordpress, и имя контейнера:

```
  wordpress:
    build:
      context: .
      dockerfile: requirements/wordpress/Dockerfile
    depends_on:
      - mariadb
    restart: unless-stopped
    volumes:
      - ./requirements/wordpress/conf/:/var/www/
    container_name: wordpress
```

А далее нам нужно подсоединить наш вордпресс к внутренней сети, по которой и будут передаваться данные между ним и базой. Пропишем эту сеть:

```
  wordpress:
    build:
      context: .
      dockerfile: requirements/wordpress/Dockerfile
    depends_on:
      - mariadb
    restart: unless-stopped
    volumes:
      - ./requirements/wordpress/conf/:/var/www/
    container_name: wordpress
	networks:
      - wp-network
```

## Шаг 3. Создание сети

А теперь мы создадим общую сеть, в которую добавим все контейнеры нашей конфигурации.

Сначала пропишем в конце docker-compose файла нашу сеть:

```
networks:
  wp-network:
    driver: bridge
```

Далее добавим эту сеть нашим контейнерам с nginx и mariadb, просто приписав им директиву network:

```
networks:
    - wp-network
```

Так же заменим нашу проверочную папку в конфигурации nginx-а на постоянное подключение к wordpress.

## Шаг 4. Создание разделов

У nginx и wordpress должен быть общий раздел для обмена данными. Можно примонтировать туда и туда одну и ту же папку, но для удобства создадим раздел, указав путь к этой папке:

```
volumes:
  wordpress:
    name: wp-volume
    driver_opts:
      o: bind
      type: none
      device: /home/${USER}/wordpress
```

Так же создадим папку wordpress в домашнем каталоге:

``mkdir ~/wordpress``

Теперь добавим этот раздел ко всем контейнерам, которые от него зависят. Таким образом вся наша конфигурация будет выглядеть так:

```
version: '3'

services:
  nginx:
    build:
      context: .
      dockerfile: requirements/nginx/Dockerfile
    container_name: nginx
    ports:
      - "443:443"
    volumes:
      - ./requirements/nginx/conf/:/etc/nginx/conf.d/
      - ./requirements/nginx/tools:/etc/nginx/ssl/
      - wp-volume:/var/www/
    restart: unless-stopped
    networks:
      - wp-network

  mariadb:
    build:
      context: .
      dockerfile: requirements/mariadb/Dockerfile
    container_name: mariadb
    ports:
      - "3306:3306"
    volumes:
      - "./requirements/mariadb/conf/:/mnt/"
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PWD:   ${MYSQL_ROOT_PASSWORD}
      WP_DATABASE_NAME: wordpress
      WP_DATABASE_USR:  ${MYSQL_USER}
      WP_DATABASE_PWD:  ${MYSQL_PASSWORD}
    networks:
      - wp-network

  wordpress:
    build:
      context: .
      dockerfile: requirements/wordpress/Dockerfile
    depends_on:
      - mariadb
    restart: unless-stopped
    volumes:
      - wp-volume:/var/www/
    container_name: wordpress
    networks:
      - wp-network

networks:
  wp-network:
    driver: bridge

volumes:
  wp-volume:
    driver_opts:
      o: bind
      type: none
      device: /home/${USER}/wordpress
```

## Шаг 3. Изменение конфигурации nginx

Нам необходимо изменить конфигурацию nginx-а чтобы тот обрабатывал только php-файлы. Для этого удалим из конфига все index.html.

Для полного счастья нам осталось раскомментировать блок nginx-а, обрабатывающий php, чтобы наш nginx.conf выглядел следующим образом:

```
server {
    listen      80;
    listen      443 ssl;
    server_name  jleslee.42.fr www.jleslee.42.fr;
    root    /var/www/;
    index index.php;
#   if ($scheme = 'http') {
#       return 301 https://jleslee.42.fr$request_uri;
#   }
    ssl_certificate     /etc/nginx/ssl/jleslee.42.fr.crt;
    ssl_certificate_key /etc/nginx/ssl/jleslee.42.fr.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    keepalive_timeout 70;
    location / {
        try_files $uri /index.php?$args;
        add_header Last-Modified $date_gmt;
        add_header Cache-Control 'no-store, no-cache';
        if_modified_since off;
        expires off;
        etag off;
    }
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}
```

Вот теперь вроде бы всё, наша конфигурация готова к запуску.


## Шаг 4. Конфигурация wordpress

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

