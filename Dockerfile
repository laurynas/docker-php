FROM php:5-apache

COPY php.ini /usr/local/etc/php/

RUN a2enmod rewrite remoteip
RUN docker-php-ext-install mysql

RUN apt-get update -y \
    && apt-get install -y libpng-dev libjpeg62-turbo-dev ssmtp \
    && apt-get clean \
    && echo "FromLineOverride=YES" >> /etc/ssmtp/ssmtp.conf \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install gd
