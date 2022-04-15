FROM php:8.1-fpm-alpine

ARG APP_ENV
ENV APP_ENV $APP_ENV
ENV XDEBUG_VERSION 3.0.4

RUN apk update \
    && apk upgrade \
    && apk add --no-cache --update oniguruma-dev libzip-dev \
    && rm -rf /var/cache/apk/*

RUN docker-php-ext-install \ 
    bcmath \
    mbstring \
    pdo_mysql \
    zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app
RUN addgroup -g 1000 -S www \
    && adduser -u 1000 -s /bin/bash -S www -G www
    
COPY --chown=www:www ./src/ /app
RUN mv .env.example .env
USER www

RUN if [ "$APP_ENV" = "dev" ] ; then \
        composer clearcache \
        && composer install --no-interaction --optimize-autoloader ; \
    else \
        composer clearcache \
        composer install --no-dev --no-interaction --optimize-autoloader ; \
    fi

EXPOSE 9000
ENTRYPOINT ["php-fpm"]