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
    php${PHP_VERSION}-dev \
    php${PHP_VERSION}-gettext \
    wget nano

WORKDIR /var/www

#RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php && \
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-en.php $$ \
    mv adminer-4.8.1-en.php index.php && \
    sed -i "s|;max_input_vars = 1000|max_input_vars = 10000|g"  /etc/php${PHP_VERSION}/php.ini
# && chown -R root:root /var/www/

EXPOSE 8080

# CMD ["/usr/sbin/php-fpm8", "/var/www/adminer-4.8.1.php"]
CMD	[ "php", "-S", "[::]:8080", "-t", "/var/www" ]