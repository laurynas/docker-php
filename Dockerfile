FROM php:7.1-apache

COPY php.ini /usr/local/etc/php/
COPY remoteip.conf /etc/apache2/conf-available/

RUN apt-get update -y \
    && apt-get install -y libpng-dev libjpeg62-turbo-dev ssmtp \
    && apt-get clean \
    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli \
    && a2enmod rewrite remoteip \
    && a2enconf remoteip
