FROM php:7.4.33-apache

COPY php.ini /usr/local/etc/php/
COPY apache/remoteip.conf /etc/apache2/conf-available/
COPY apache/tuning.conf /etc/apache2/conf-available/
COPY patches/cve-2026-109618-109619.diff /tmp/cve-2026-109618-109619.diff

RUN set -eux; \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until; \
    sed -i \
      -e 's/deb.debian.org/archive.debian.org/g' \
      -e 's/security.debian.org/archive.debian.org/g' \
      -e '/bullseye-updates/d' \
      /etc/apt/sources.list; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update -y; \
    apt-get install -y --no-install-recommends --reinstall debian-archive-keyring; \
    apt-get install -y --no-install-recommends \
      $PHPIZE_DEPS \
      apache2-dev \
      libargon2-dev \
      libcurl4-openssl-dev \
      libonig-dev \
      libreadline-dev \
      libsodium-dev \
      libsqlite3-dev \
      libssl-dev \
      libxml2-dev \
      zlib1g-dev \
      patch \
      libpng-dev \
      libjpeg62-turbo-dev \
      libzip-dev \
      msmtp \
    ; \
    docker-php-source extract; \
    cd /usr/src/php; \
    patch -p1 --fuzz=0 < /tmp/cve-2026-109618-109619.diff; \
    rm /tmp/cve-2026-109618-109619.diff; \
    export \
      CFLAGS="$PHP_CFLAGS" \
      CPPFLAGS="$PHP_CPPFLAGS" \
      LDFLAGS="$PHP_LDFLAGS" \
    ; \
    ./configure $(php-config --configure-options); \
    make -j"$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    find /usr/local -type f -perm '/0111' -exec sh -euxc 'strip --strip-all "$@" || :' -- '{}' +; \
    cd /; \
    docker-php-ext-configure gd --with-jpeg; \
    docker-php-ext-install gd; \
    docker-php-ext-install mysqli; \
    docker-php-ext-install opcache; \
    docker-php-ext-install zip; \
    docker-php-source delete; \
    a2enmod rewrite remoteip; \
    a2enconf remoteip; \
    a2enconf tuning; \
    apt-mark auto '.*' > /dev/null; \
    [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
    apt-mark manual msmtp; \
    find /usr/local -type f -executable -exec ldd '{}' ';' \
      | awk '/=>/ { print $(NF-1) }' \
      | sort -u \
      | xargs -r dpkg-query --search \
      | cut -d: -f1 \
      | sort -u \
      | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*; \
    php --version; \
    php -i | grep -F max_multipart_body_parts

COPY msmtp/msmtprc /etc/msmtprc

ENV APACHE_KEEP_ALIVE On
ENV APACHE_MAX_KEEP_ALIVE_REQUESTS 10
ENV APACHE_KEEP_ALIVE_TIMEOUT 1
ENV APACHE_START_SERVERS 1
ENV APACHE_MIN_SPARE_SERVERS 1
ENV APACHE_MAX_SPARE_SERVERS 5
ENV APACHE_MAX_REQUEST_WORKERS 150
ENV APACHE_MAX_CONNECTIONS_PER_CHILD 1024
