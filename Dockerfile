FROM php:7.3-apache

# Required packages & php extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        git \
        cron \
        libfreetype6-dev \
        libgmp-dev \
        libjpeg-dev \
        libmagickwand-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libssl-dev \
        libxml2-dev \
        libz-dev \
        libzip-dev \
        nano \
        openssh-server \
        postgresql-client \
        unzip \
        zlib1g-dev \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install exif \
    && docker-php-ext-install gmp \
    && docker-php-ext-install intl \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install pgsql \
    && docker-php-ext-install soap \
    && docker-php-ext-install sockets \
    && docker-php-ext-install zip

# Free space
RUN rm -r /var/lib/apt/lists/*

#  Enable mod_rewrite
RUN a2enmod rewrite

# Fetch TinyTinyRSS sources
WORKDIR /var/www/html
RUN curl -SL https://git.tt-rss.org/fox/tt-rss/archive/master.tar.gz | tar xzC /var/www/html --strip-components 1 && chown www-data:www-data -R /var/www

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Override memory limit
RUN echo "memory_limit = 1024M" >> $PHP_INI_DIR/php.ini

# Environment variables exposes TTRSS configuration
ENV SELF_URL_PATH http://127.0.0.1:80
ENV DB_TYPE pgsql
ENV DB_HOST localhost
ENV DB_USER fox
ENV DB_NAME fox
ENV DB_PASS XXXXXX
ENV DB_PORT 5432
ENV PHP_EXECUTABLE /usr/bin/php
ENV SINGLE_USER_MODE false
ENV SIMPLE_UPDATE_MODE true
COPY --chown=www-data:www-data ./config.php /var/www/html/config.php

# Customized sanity check
COPY sanity_check.php /var/www/html/include/sanity_check.php

# Updater
ADD updater.sh /
RUN chown www-data:www-data /updater.sh
RUN chmod u+x /updater.sh

# Entrypoint
COPY start.sh /usr/local/bin/start
RUN chmod u+x /usr/local/bin/start
CMD ["/usr/local/bin/start"]
