# Предварительная настройка Docker

> Не забудь перед каждым новым этапом сборки

## Шаг 1. Установка и конфигурация sudo

Тепрь нам нужно начинать работать с докером. Для начала сделаем его удобным для нас, а так же протестируем его работу.

> Все действия данного гайда лучше выполнять через терминал чтобы было возможно копипастить команды и код

На этом этапе нам понадобится наш терминал. Логинимся через терминал, а не в virtualbox, сначала под суперпользователем:

```ssh root@localhost -p 42```

По умолчанию докер запускается либо с привилегией суперпользователя, либо любым пользователем, состоящем в группе docker и обладающим возможность делать запросы под суперпользователем (например, через sudo). 

Установим утиллиту sudo, позволяющую пользователю делать запросы от имени root. Для этого вводим команду:

```apt install sudo```

После успешной установки правим конфиг /etc/sudoers: ```nano /etc/sudoers```

Наша задача - добавить запись с именем нашего пользователя и правами, равнозначными правам root:

![Настройка Docker](media/setting_docker/step_5.png)

![Настройка Docker](media/setting_docker/step_6.png)

Сохраняем изменения и закрываем файл.

## Шаг 2. Добавление пользователя в группу docker

Теперь добавим нашего пользователя ```user``` в группу ```docker```. Это позволит нам выполнять команды докера без необходимости вызова sudo. (да, мы установили sudo не для докера, а для удобства работы с системой).

Вот так выглядит список групп нашего пользователя сейчас (```groups user```):

![Настройка Docker](media/setting_docker/step_0.png)

Добавим же нашего пользователя в группу командой 

```usermod -aG docker user```

И проверим, что добавление произошло:

```groups user```

![Настройка Docker](media/setting_docker/step_1.png)

Как мы можем видеть, в списке групп в самом конце добавилась группа docker. Это значит, что теперь мы можем вызывать наш докер из под обычного пользователя (если мы проделали добавление в группу не под root, а под пользователем через sudo, надо перелогиниться).

## Шаг 3. Тестовая конфигурация

Так переключимся же на нашего пользователя и перейдём в его домашний каталог:

```su user```

```cd ~/```

Так же скачаем в корень простую конфигурацию из одного докер-контейнера для проверки работы системы:

```git clone https://github.com/codesshaman/simple_docker_nginx_html.git```

![Настройка Docker](media/setting_docker/step_2.png)

Теперь мы можем переходить в эту папку и запускать контейнер:

```cd simple_docker_nginx_html```

```docker-compose up -d```

Через некоторое время наш контейнер сбилдится и мы увидим сообщение об успешном запуске:

![Настройка Docker](media/setting_docker/step_3.png)

Это значит, что мы можем протестировать запущенный контейнер и правильность настройки конфигурации. Если на шаге 01 при пробросе портов мы всё сделали правильно, значит 80-й порт открыт, и зайдя в браузер по адресу локального хоста ```127.0.0.1``` мы увидим следующую картину:

![Настройка Docker](media/setting_docker/step_4.png)

Если вдруг мы видим что-либо другое, значит, у нас не открыты порты или 80-й порт чем-то занят на хостовой машине. Пройдитесь по гайду 01 и удостоверьтесь, что порты открыты, а так же проверьте все запущенные приложения. Если среди них есть сервера или иные приложения для работы с локальным хостом, отключаем их.

## Шаг 4. Создание директорий и файлов проекта

Далее нам нужно создать множество директорий и файлов в соответствии с заданием.

Это рутинное занятие, в котором нет ничего сложного: команда ```mkdir``` создаёт директорию, команда ```touch``` создаёт файл, ```cd``` перемещает нас по относительному или абсолютному пути, прописанному после команды, а ```cd ..``` переносит нас на каталог выше. Так же ``pwd`` показывает где мы находимся, ``cd ~`` возвращает нас в домашний каталог.

Если нет желания заниматься данной рутиной, я сделал скрипт make_directories.sh, который выполняет все эти действия автоматически. Вот его код:

```
#!/bin/bash
mkdir project
mkdir project/srcs
touch project/Makefile
mkdir project/srcs/requirements
touch project/srcs/docker-compose.yml
touch project/srcs/.env
echo "DOMAIN_NAME=jleslee.21.school" > project/srcs/.env
echo "CERT_=./project/srcs/requirements/nginx/conf/jleslee.cert" >> project/srcs/.env
echo "KEY_=./project/srcs/requirements/nginx/conf/jleslee.key" >> project/srcs/.env
echo "MYSQL_ROOT_PASSWORD=123456" >> project/srcs/.env
echo "MYSQL_USER=user" >> project/srcs/.env
echo "MYSQL_PASSWORD=1234" >> project/srcs/.env
mkdir project/srcs/requirements/bonus
mkdir project/srcs/requirements/mariadb
mkdir project/srcs/requirements/mariadb/conf
mkdir project/srcs/requirements/mariadb/tools
touch project/srcs/requirements/mariadb/Dockerfile
touch project/srcs/requirements/mariadb/.dockerignore
mkdir project/srcs/requirements/nginx
mkdir project/srcs/requirements/nginx/conf
mkdir project/srcs/requirements/nginx/tools
touch project/srcs/requirements/nginx/Dockerfile
touch project/srcs/requirements/nginx/.dockerignore
mkdir project/srcs/requirements/tools
mkdir project/srcs/requirements/wordpress
```

Создадим файл с расширением .sh, закинув туда данный код:

![Создание папок](media/create_folders/make_script.png)

Его необходимо положить в ту папку, где будет проект (например, в корень - ``~/``), дать ему разрешение на исполнение - ``chmod +x make_directories.sh`` и запустить ``./make_directories.sh``.

И Вуаля - все директории нашего проекта (и даже некоторые необходимые файлы в них) созданы! Ну а если всё-таки есть желание изучать bash и сделать всё руками, можно посмотреть на содержание скрипта. В нём я использую относительные пути, находясь в корневом каталоге пользователя, однако по каталогам можно перемещаться и делать папки внутри других папок.

![Создание папок](media/create_folders/run_script.png)