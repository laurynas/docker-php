FROM php:7.1-apache

COPY php.ini /usr/local/etc/php/
COPY apache/remoteip.conf /etc/apache2/conf-available/
COPY apache/tuning.conf /etc/apache2/conf-available/

RUN apt-get update -y \
    && apt-get install -y libpng-dev libjpeg62-turbo-dev ssmtp zlib1g-dev \
    && apt-get clean \
    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install opcache \
    && docker-php-ext-install zip \
    && a2enmod rewrite remoteip \
    && a2enconf remoteip \
    && a2enconf tuning

ENV APACHE_KEEP_ALIVE On
ENV APACHE_MAX_KEEP_ALIVE_REQUESTS 10
ENV APACHE_KEEP_ALIVE_TIMEOUT 1
ENV APACHE_START_SERVERS 1
ENV APACHE_MIN_SPARE_SERVERS 1
ENV APACHE_MAX_SPARE_SERVERS 5
ENV APACHE_MAX_REQUEST_WORKERS 150
ENV APACHE_MAX_CONNECTIONS_PER_CHILD 1024
