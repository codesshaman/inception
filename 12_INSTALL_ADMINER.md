# Административный интерфейс adminer

Теперь нам нужно установить административную панель adminer. По сути это лёгкая СУБД, которая написана всего лишь одним php-файлом!

Стало быть, для её развёртывания надо установить в контейнер php нужной нам версии, скачать нашу панельку и скормить её интерпретатору php. Звучит просто. Главное - не забыть открыть порты.

Зачем она вообще нужна? Для того, чтобы можно было открыть базу данных в графическом режиме и ~~следить за манекенами~~ делать в ней любые нужные нам операции без SQL-запросов и ручных команд.

![настройка vsftpd](media/stickers/manekens.png)

Поехали!

# Шаг 1. Создание Dockerfile

Заходим на [официальный сайт adminer](https://www.adminer.org/ "скачать adminer") и смотрим особенности и зависимости:

![настройка vsftpd](media/bonus_part/step_12.png)

Как мы можем видеть, adminer работает с php-8 и поддерживает нашу Машу. Но как понять, какие именно пакеты необходимы для adminer в качестве зависимостей? Я не нашёл эту информацию в открытых источниках, потому подошёл к этому вопросу с другой стороны.

Аналогом adminer является PhpMyAdmin, и работает эта штука на том же php. Но в отличие от Adminer-а, все зависимости PhpMyAdmin прекрасно задокументированы в [alpine-овской wiki](https://wiki.alpinelinux.org/wiki/PhpMyAdmin "список пакетов для PMA"). Именно инструкция для PMA помогла мне запустить adminer: я взял все зависимости отсюда из строки "Install the additional packages" и прогнал их через [поиск пакетов](https://pkgs.alpinelinux.org/packages?name=&branch=edge&repo=&arch=&maintainer= "поиск пакетов alpine"), подставляя вместо php7- наш текущий php8-.

Отсеялись php8-mcrypt, php8-xmlrpc и, на удивление, php8-json. Удивление всё же оказалось приятным - если первые два пакета просто не реализованы ещё на alpine, то модуль json просто вошёл в ядро php начиная с версии 8.

![настройка vsftpd](media/stickers/delete.png)

Так же я убрал ненужный нам lighttpd и fast cgi. Итак, список пакетов сформирован, приступим к созданию Dockerfile:

``nano bonus/adminer/Dockerfile``

За основу возьмём всё тот же alpine 3.16, занесём в переменную версию php и установим все необходимые нам пакеты из готового списка:

```
FROM alpine:3.16

ARG PHP_VERSION=8

RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-session \
    php${PHP_VERSION}-iconv \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-cgi \
    php${PHP_VERSION}-pdo \
    php${PHP_VERSION}-pdo_mysql \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-posix \
    php${PHP_VERSION}-gettext \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-ctype \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-simplexml \
    wget

WORKDIR /var/www

RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php && \
    mv adminer-4.8.1.php index.php && chown -R root:root /var/www/

EXPOSE 8080

CMD	[ "php", "-S", "[::]:8080", "-t", "/var/www" ]
```

