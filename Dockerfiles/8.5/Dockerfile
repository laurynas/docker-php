FROM php:8.5-apache

COPY php.ini /usr/local/etc/php/
COPY apache/remoteip.conf /etc/apache2/conf-available/
COPY apache/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
COPY apache/tuning.conf /etc/apache2/conf-available/

RUN set -eux; \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        libpng-dev \
        libjpeg62-turbo-dev \
        libzip-dev \
        msmtp \
    ; \
    docker-php-ext-configure gd --with-jpeg; \
    docker-php-ext-install gd zip; \
    a2enmod rewrite remoteip; \
    a2enconf remoteip tuning;

COPY msmtp/msmtprc /etc/msmtprc

ENV APACHE_KEEP_ALIVE On
ENV APACHE_MAX_KEEP_ALIVE_REQUESTS 10
ENV APACHE_KEEP_ALIVE_TIMEOUT 1
ENV APACHE_START_SERVERS 1
ENV APACHE_MIN_SPARE_SERVERS 1
ENV APACHE_MAX_SPARE_SERVERS 2
ENV APACHE_MAX_REQUEST_WORKERS 4
ENV APACHE_MAX_CONNECTIONS_PER_CHILD 200
