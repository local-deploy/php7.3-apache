FROM php:7.3-apache

LABEL maintainer="dl@varme.pw"

ENV TZ=Europe/Moscow
ENV DOCUMENT_ROOT /var/www/html

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG COMPOSER_VERSION="2.1.9"

RUN set -ex && \
    apt-get update && apt-get install -y --no-install-recommends \
        software-properties-common \
        git \
        zip \
        apache2 \
        libfreetype6-dev \
        libpng-dev \
        libjpeg-dev \
        libgmp-dev \
        libxml2-dev \
        zlib1g-dev \
        libncurses5-dev \
        libldb-dev \
        libldap2-dev \
        libicu-dev \
        libmemcached-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libsqlite3-dev \
        libzip-dev \
        curl \
        ssmtp \
        wget \
        nano \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug-3.1.1 \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql exif pcntl bcmath gd soap zip opcache

RUN wget https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar -O /usr/local/bin/composer && \
    chmod a+rx /usr/local/bin/composer

RUN groupadd --gid 1000 1000 && \
    usermod --non-unique --uid 1000 www-data && \
    usermod --gid 1000 www-data

RUN mkdir /var/www/.composer && \
    mkdir /var/www/.ssh

RUN chown www-data:www-data /var/www -R && \
    chown www-data:www-data /var/www/.composer && \
    chown www-data:www-data /var/www/.ssh

COPY ./php.ini /usr/local/etc/php
COPY ./ssmtp.conf /etc/ssmtp/
COPY ./.bashrc /var/www/

USER www-data:www-data
