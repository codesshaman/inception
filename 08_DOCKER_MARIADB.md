# Создание контейнера Mariadb

На этом шаге размеры моих снапшотов привысили два гига, и мне стало сложно качать их с облака, так как файлам более 2-х гигабайт mail урезает скорость.

Так как мне всё равно не нужно будет возвращаться к старым снапшотам, я решил оставить только новые конфигурации, а всё старое удалить.

Вот как выглядел список моих снапшотов до удаления:

![настройка mariadb](media/remove_snapshots/step_0.png)

Вот сколько их осталось после. Как можно заметить, я оставил только последние. 

![настройка mariadb](media/remove_snapshots/step_1.png)

Проблема низкой скорости загрузки решилась.

## Шаг 1. Скрипт настройки mariadb

Посмотрим, чего же от нас, простых русских девопсов, хотят французы:

![настройка mariadb](media/docker_mariadb/step_0.png)

А всё того же, что от настроек nginx. Dockerfile и какие-нибудь конфигурации. Что хранить в папке tools я не представляю, видимо фантазия у французов развита несколько лучше, чем у русских разработчиков. Я не сторонник различных вынесений баз данных или логов за пределы контейнера с последующими мучениями вокруг прав доступа на эти файлы, потому папку tools я пока оставлю нетронутой.

Но вот папку conf мы задействуем для конфигурации запуска mariadb:

```cd ~/project/srcs/```

```nano requirements/mariadb/conf/start.sh```

Содержимое файла я подглядел в интернете, и это bash и sql:

```
#!/bin/bash
if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi
if [ ! -d "/var/lib/mysql/mysql" ]; then
	chown -R mysql:mysql /var/lib/mysql
	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null
	tfile=`mktemp`
	if [ ! -f "$tfile" ]; then
		return 1
	fi
	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM	mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PWD';
CREATE DATABASE $WP_DATABASE_NAME CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '$WP_DATABASE_USR'@'%' IDENTIFIED by '$WP_DATABASE_PWD';
GRANT ALL PRIVILEGES ON $WP_DATABASE_NAME.* TO '$WP_DATABASE_USR'@'%';
FLUSH PRIVILEGES;
EOF
	/usr/bin/mysqld --user=mysql --bootstrap < $tfile
	rm -f $tfile
fi
sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf
exec /usr/bin/mysqld --user=mysql --console
```

Скрипт создаст тестовую базу, проверив нашу Машу на работоспособность.

## Шаг 2. Создание Dockerfile

Тут всё будет несколько по-другому, чем с nginx. Ищем на dockerhub уже непосредственно голый alpine и на него накатываем Машу. Звучит пошловато, но именно этим мы сейчас и займёмся.

```nano requirements/mariadb/Dockerfile```

Убеждаемся, что существует ```alpine:latest``` и берём его за основу нашей системы:

```
FROM alpine:latest
RUN	apk update && apk upgrade && apk add --no-cache \
        mariadb \
        mariadb-client
COPY conf/start.sh /tmp/start.sh
CMD ["sh", "/tmp/start.sh"]
```

Как видим, всё предельно просто. Теперь опишем то, как мы будем запускать это в docker-compose.

## Шаг 3. Создание docker-compose секции

Если мы находимся непосредственно в папке srcs, мы откроем наш docker-compose напрямую:

```nano docker-compose.yml```

Теперь ниже нашего nginx опишем секцию с нашей Машей. Переменные берём из .env - файла, созданного скриптом на этапе создания директорий.

Посмотрим, что в нашем файле .env:

```cd ~/project/srcs/ && cat .env```

И увидим следующий вывод:

```
DOMAIN_NAME=jleslee.42.fr
CERT_=./requirements/tools/jleslee.42.fr.crt
KEY_=./requirements/tools/jleslee.42.fr.key
MYSQL_ROOT_PASSWORD=123456
MYSQL_USER=dbuser
MYSQL_PASSWORD=1234
```

Копируем названия некоторых наших переменных в docker-compose, снабдив их $ и скобками:

```nano docker-compose.yml```

```
  mariadb:
    build: requirements/mariadb/
    container_name: mariadb
    ports:
      - "3306:3306"
    volumes:
      - "~/Desktop/inception/mariadb:/var/lib/mysql"
    networks:
      - backend
    restart: always
    environment:
      MYSQL_ROOT_PWD:   ${MYSQL_ROOT_PWD}
      WP_DATABASE_NAME: ${WP_DATABASE_NAME}
      WP_DATABASE_USR:  ${WP_DATABASE_USR}
      WP_DATABASE_PWD:  ${WP_DATABASE_PWD}
```

