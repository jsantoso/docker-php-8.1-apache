FROM php:8.1-apache
WORKDIR /var/www

LABEL maintainer="Jeffrey Santoso <jeffrey.k.santoso@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC

RUN apt-get update
RUN apt-get install -y \
        apt-utils \
        vim \
        libpng-dev \
        zlib1g-dev \
        libpspell-dev \
        libldap2-dev \
        libcurl4 \
        libcurl3-dev \ 
        libbz2-dev \ 
        libpq-dev \
        libxml2-dev \
        libz-dev \
        libzip4 \
        libzip-dev \
        libmemcached-dev \
        libmcrypt-dev \
        libreadline-dev \
        librabbitmq-dev \
        unzip \
        libonig-dev \
        iproute2 \
        iputils-ping \
        imagemagick \
        lftp \
        poppler-utils \
        zip \
        pdftk \
        expect \
        mkisofs \
        dcmtk \
        libmagickwand-dev \
        unixodbc \
        unixodbc-dev

RUN  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite

RUN echo alias ll=\'ls -lF\' >> /root/.bashrc

ENV PHP_ERROR_REPORTING  E_ALL & ~E_NOTICE
ENV XDEBUG_HOST host.docker.internal
ENV XDEBUG_PORT 9000

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

RUN /usr/local/bin/docker-php-ext-install mbstring
RUN /usr/local/bin/docker-php-ext-install iconv
RUN /usr/local/bin/docker-php-ext-install gd
RUN /usr/local/bin/docker-php-ext-install bz2
RUN /usr/local/bin/docker-php-ext-install pdo
RUN /usr/local/bin/docker-php-ext-install pdo_pgsql
RUN /usr/local/bin/docker-php-ext-install pgsql
RUN /usr/local/bin/docker-php-ext-install soap
RUN /usr/local/bin/docker-php-ext-install xml
RUN /usr/local/bin/docker-php-ext-install zip
RUN /usr/local/bin/docker-php-ext-install bcmath
RUN /usr/local/bin/docker-php-ext-install ldap
RUN /usr/local/bin/docker-php-ext-install curl
RUN /usr/local/bin/docker-php-ext-install sockets
RUN /usr/local/bin/docker-php-ext-install ctype

RUN docker-php-ext-configure pdo_odbc --with-pdo-odbc=unixODBC,/usr
RUN /usr/local/bin/docker-php-ext-install pdo_odbc

ADD etc/ImageMagick/policy.xml /etc/ImageMagick-6/policy.xml

RUN pecl install xmlrpc-beta
RUN docker-php-ext-enable xmlrpc

RUN pecl install redis
RUN docker-php-ext-enable redis

RUN pecl install amqp-beta
RUN docker-php-ext-enable amqp

RUN pecl install xdebug

RUN pecl install memcached
RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

RUN pecl install imagick
RUN docker-php-ext-enable imagick

ADD conf.d/php.ini /etc/php/8.1/php.ini
ADD conf.d/xdebug.ini /etc/php/8.1/xdebug.ini

RUN mkdir -p /etc/php/8.1/fpm/conf.d
RUN ln -s /etc/php/8.1/php.ini /etc/php/8.1/fpm/conf.d/90-tris.ini
RUN ln -s /etc/php/8.1/xdebug.ini /etc/php/8.1/fpm/conf.d/90-xdebug.ini

RUN mkdir -p /etc/php/8.1/cli/conf.d
RUN ln -s /etc/php/8.1/php.ini /etc/php/8.1/cli/conf.d/90-tris.ini
RUN ln -s /etc/php/8.1/xdebug.ini /etc/php/8.1/cli/conf.d/90-xdebug.ini

RUN mkdir -p /usr/local/etc/php/conf.d
RUN ln -s /etc/php/8.1/php.ini /usr/local/etc/php/conf.d/90-tris.ini
RUN ln -s /etc/php/8.1/xdebug.ini /usr/local/etc/php/conf.d/90-xdebug.ini

RUN rm /etc/apache2/sites-enabled/000-default.conf
COPY site.conf /etc/apache2/sites-available/site.conf
RUN ln -s /etc/apache2/sites-available/site.conf /etc/apache2/sites-enabled/site.conf

EXPOSE 80

WORKDIR /var/www

COPY start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
