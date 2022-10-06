# Административный интерфейс adminer

Теперь нам нужно установить административную панель adminer. По сути это лёгкая СУБД, которая написана всего лишь одним php-файлом!

Стало быть, для её развёртывания надо установить в контейнер php нужной нам версии, скачать нашу панельку и скормить её интерпретатору php. Звучит просто. Главное - не забыть открыть порты.

Поехали!

# Шаг 1. Создание Dockerfile

Заходим на [официальный сайт adminer](https://www.adminer.org/ "скачать adminer") и смотрим особенности и зависимости:

![настройка vsftpd](media/bonus_part/step_12.png)

Как мы можем видеть, adminer работает с php-8 и поддерживает нашу Машу. Стало быть, мы можем использовать то, что использовали при создании wordpress.

``nano bonus/adminer/Dockerfile``

На официальном же сайте копируем актуальную ссылку на adminer. Можно выбрать полную версию, только английскую, версию только для mysql и английскую для mysql. Я выбрал полную. Качаю по официальной ссылке при помощи wget.

```
FROM alpine:3.16

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
    wget nano

WORKDIR /var/www

RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php && \
    mv adminer-4.8.1.php index.php && chown -R root:root /var/www/

EXPOSE 8080

CMD	[ "php", "-S", "[::]:8080", "-t", "/var/www" ]
```

