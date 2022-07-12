FROM php:8.1-apache
MAINTAINER qingjiubaba <iamwhs@88.com>
COPY entrypoint.sh /
RUN apt update && apt upgrade -y \
    && apt install imagemagick libmagickwand-dev -y \
    && pecl install imagick \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable imagick \
    && a2enmod rewrite \
    && apt-get clean \
    && echo 'apc.enable_cli=1' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
    && echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini \
    && mkdir -p /var/www/data \
    && chown -R www-data:root /var/www \
    && chmod -R g=u /var/www \
    && chmod a+x /entrypoint.sh

COPY ./ /var/www/lsky/
COPY ./000-default.conf /etc/apache2/sites-enabled/
COPY ./docker-php-upload.ini /usr/local/etc/php/conf.d/
COPY ./opcache-recommended.ini /usr/local/etc/php/conf.d/
WORKDIR /var/www/html
VOLUME /var/www/html
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apachectl","-D","FOREGROUND"]
