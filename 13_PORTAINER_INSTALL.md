# Самописный сайт и установка portainer



## Шаг 1. Самописный сайт

По заданию мы должны создать самописный сайт используя ту технологию, которая нам ближе. Здесь каждый выбирает сам, какой язык использовать и какой контейнер создавать. Те, кому нравится JS, могут использовать контейнер с nodejs и react, любители питона могут создать страницу на django, php-гуру могут юзать laravel или symfony. Я не стал заморачиваться и использовал готовое решение для создания страницы - wysiwyg-редактор для генерации статичного html.

Сам сайт лежит в ``bonus/website/conf``, его можно открыть прямо в браузере, так как это html.

## Шаг 2. Dockerfile

Dockerfile берём из нашего nginx, так как html-сайт мы будем крутить на том же nginx-е. Меняем дефолтный конфиг, лежащий по адресу ``/etc/nginx/http.d/default.conf``, поместив туда простенький код указывающий другую локацию вместо стандартной (/var/www):

```
FROM alpine:3.16
RUN	apk update && apk upgrade && apk add --no-cache nginx

RUN echo "server {" > /etc/nginx/http.d/default.conf && \
    echo "root    /var/www;" >> /etc/nginx/http.d/default.conf && \
    echo "location / {" >> /etc/nginx/http.d/default.conf && \
    echo "    try_files \$uri /index.html;" >> /etc/nginx/http.d/default.conf && \
    echo "}}" >> /etc/nginx/http.d/default.conf

COPY bonus/website/conf/* /var/www

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Копируем всё содержимое сайта при помощи маски * в нашу папку /var/www. Открываем 80-й порт (прокидывать не надо, в системе порт уже открыт). Ну и запускаем nginx без демонизации.

## Шаг 3. Секция в docker-compose

Тут мы просто берём те же исходные данные, что и у wordpress, но удаляем всё лишнее.

```
  website:
    build:
      context: .
      dockerfile: bonus/website/Dockerfile
    container_name: website
    ports:
      - "80:80"
    restart: always
```

Порт 80 у нас свободен, подключим его


Ура, Казань, я закончил писать свой гайд!

![настройка vsftpd](media/stickers/ufa.png)

Теперь можно ставить мне плюсик в ~~карму~~ гите и сдавать inception с бонусами. A ~~Добби свободен~~ я пойду награжу себя обедом в доброй столовой (на правах рекламы*).