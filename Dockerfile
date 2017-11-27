FROM php:7.1-apache

COPY php.ini /usr/local/etc/php/

RUN a2enmod rewrite
RUN docker-php-ext-install mysqli

RUN apt-get update -y \
    && apt-get install -y libpng-dev libjpeg62-turbo-dev \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install gd
