FROM php:7.1.27-fpm-alpine

WORKDIR /data/web

ADD php.ini /usr/local/etc/php/
ADD www.conf /usr/local/etc/php-fpm.d/
RUN chmod 777 /data/web/ -R

#安装调用组件
#RUN apk add --no-cache --virtual .build-deps wget \
#  libmcrypt-dev \
#  cyrus-sasl-dev\
#  automake \
#  git \
#  openssl-dev \
#  autoconf \
#  g++ make cmake  \
#  pcre-dev \
#  re2c \
#  libmemcached-dev zlib-dev libgsasl-dev cyrus-sasl-dev \
#  libxml2-dev \
#  freetype-dev \
#  libjpeg-turbo-dev \
#  libpng-dev \
#  libmcrypt-dev \
#  libxml2 \
#  libzip-dev 

RUN apk add autoconf automake make cmake

# add packages
RUN apk add supervisor git bash openssl openssh
RUN apk add autoconf g++ make cmake pcre-dev re2c automake
RUN apk add linux-headers zlib-dev openssl-dev
RUN apk add libmcrypt-dev libxslt-dev
RUN apk add freetype freetype-dev libpng-dev libjpeg-turbo-dev libwebp-dev
RUN apk add libzip-dev
RUN apk add postgresql-dev
RUN apk add libtool
RUN apk add m4
RUN apk add gmp gmp-dev
#RUN apk add nginx go nodejs
# install some extension
RUN docker-php-ext-install gd
#RUN docker-php-ext-install intl
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pdo pdo_pgsql
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install sysvsem
RUN docker-php-ext-install gmp
#RUN docker-php-ext-install zip
#RUN pecl install igbinary && docker-php-ext-enable igbinary

ENV IGBINARY_VERSION=3.0.1
RUN set -xe \
    && curl -fSL http://pecl.php.net/get/igbinary-${IGBINARY_VERSION}.tgz -o igbinary.tar.gz \
    && mkdir -p /tmp/igbinary \
    && tar -xf igbinary.tar.gz -C /tmp/igbinary --strip-components=1 \
    && rm igbinary.tar.gz \
    && docker-php-ext-configure /tmp/igbinary --enable-igbinary \
    && docker-php-ext-install /tmp/igbinary \
    && rm -r /tmp/igbinary 

  
# compile phalcon
#ENV PHALCON_VERSION=3.4.3
#RUN curl -fSL https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz -o cphalcon.tar.gz \
#    && mkdir -p cphalcon \
#    && tar -xf cphalcon.tar.gz -C cphalcon --strip-components=1 \
#    && rm cphalcon.tar.gz \
#    && cd cphalcon/build \
#    && sh install \
#    && rm -rf cphalcon \
#    && docker-php-ext-enable phalcon

# add mongodb extension
#RUN set -xe && \
#    pecl install mongodb-1.3.4 && \
#    docker-php-ext-enable mongodb

ENV MONGODB_VERSION=1.7.2
# compile mongodb extension
RUN set -xe \
    && curl -fSL http://pecl.php.net/get/mongodb-${MONGODB_VERSION}.tgz -o mongodb.tar.gz \
    && mkdir -p /tmp/mongodb \
    && tar -xf mongodb.tar.gz -C /tmp/mongodb --strip-components=1 \
    && rm mongodb.tar.gz \
    && docker-php-ext-configure /tmp/mongodb --enable-mongodb \
    && docker-php-ext-install /tmp/mongodb \
    && rm -r /tmp/mongodb
        
#ENV REDIS_VERSION=3.1.3
#RUN cd /tmp \
#    && pecl download redis-${REDIS_VERSION} \
#    && tar zxvf redis-${REDIS_VERSION}.tgz \
#    && cd redis-${REDIS_VERSION} \
#    && phpize \
#    && ./configure --enable-redis-igbinary \
#    && make \
#    && make install \
#    && docker-php-ext-enable redis \
#    && rm -rf /tmp/reids-${REDIS_VERSION}*

ENV REDIS_VERSION=3.1.3
RUN set -xe \
    && apk add --no-cache --virtual .build-deps autoconf g++ make pcre-dev re2c \
    && curl -fSL http://pecl.php.net/get/redis-${REDIS_VERSION}.tgz -o redis.tar.gz \
    && mkdir -p /tmp/redis \
    && tar -xf redis.tar.gz -C /tmp/redis --strip-components=1 \
    && rm redis.tar.gz \
    && docker-php-ext-configure /tmp/redis --enable-redis --enable-redis-igbinary \
    && docker-php-ext-install /tmp/redis \
    && rm -r /tmp/redis


#RUN pecl channel-update pecl.php.net && pecl install xdebug-2.5.5 && docker-php-ext-enable xdebug

#RUN git clone https://github.com/tideways/php-profiler-extension.git /usr/src/php/ext/tideways \
#    && cd /usr/src/php/ext/tideways\
#    && docker-php-ext-install tideways 

# compile a extension
ENV SWOOLE_VERSION=4.5.2
RUN set -xe \
    && curl -fSL http://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz -o swoole.tar.gz \
    && mkdir -p /tmp/swoole \
    && tar -xf swoole.tar.gz -C /tmp/swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && docker-php-ext-configure /tmp/swoole --enable-swoole --enable-openssl \
    && docker-php-ext-install /tmp/swoole \
    && rm -r /tmp/swoole

ENV RABBITMQ_VERSION v0.8.0
RUN git clone --branch ${RABBITMQ_VERSION} https://github.com/alanxz/rabbitmq-c.git /tmp/rabbitmq \
            && cd /tmp/rabbitmq \
            && mkdir build && cd build \
            && cmake .. \
            && cmake --build . --target install \
            && cp -r /usr/local/lib64/* /usr/lib/ 
            
#    && git clone --branch ${PHP_AMQP_VERSION} https://github.com/pdezwart/php-amqp.git /tmp/php-amqp \
#            && cd /tmp/php-amqp \
#            && phpize \
#            && ./configure \
#            && make  \
#            && make install \
#            && make test \
#    && docker-php-ext-enable amqp   

ENV PHP_AMQP_VERSION 1.10.2
RUN set -ex \
    && curl -fSl http://pecl.php.net/get/amqp-${PHP_AMQP_VERSION}.tgz -o amqp.tar.gz \
    && mkdir -p /tmp/amqp \
    && tar -xf amqp.tar.gz -C /tmp/amqp  --strip-components=1 \
    && rm amqp.tar.gz \
    && docker-php-ext-configure /tmp/amqp --enable-amqp \
    && docker-php-ext-install /tmp/amqp \
    && rm -r /tmp/amqp

RUN set -ex \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/freetype2/freetype \
        --with-jpeg-dir=/usr/include \
        --with-png-dir=/usr/include \
    && docker-php-ext-install soap gd bcmath zip opcache iconv  pdo pcntl sockets shmop xmlrpc \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

RUN set -xe &&  wget -q -O - http://www.xunsearch.com/scws/down/scws-1.2.1.tar.bz2 | tar xjf - &&\
    cd scws-1.2.1 && \
    sed -i '29i #endif '  ./libscws/xdb.c && \
    sed -i '29i #include <sys/file.h> '  ./libscws/xdb.c && \
    sed -i '29i #ifdef HAVE_FLOCK'  ./libscws/xdb.c && \
     ./configure && make install && \
    git clone https://github.com/hightman/scws.git /usr/local/php/ext/scws && \
    cd /usr/local/php/ext/scws/phpext \
    && phpize \
    && ./configure \
    && make  \
    && make install \
    && make test \
    && docker-php-ext-enable scws 

ENV APCU_VERSION=5.1.11
# compile apcu extension
RUN set -xe \
    && apk add --no-cache --virtual .build-deps pcre-dev pcre \
    && curl -fsSL http://pecl.php.net/get/apcu-${APCU_VERSION}.tgz -o apcu.tar.gz \
    && mkdir -p /tmp/apcu \
    && tar -xf apcu.tar.gz -C /tmp/apcu --strip-components=1 \
    && rm apcu.tar.gz \
    && docker-php-ext-configure /tmp/apcu --enable-apcu \
    && docker-php-ext-install /tmp/apcu \
    && rm -r /tmp/apcu

RUN rm -rf /tmp/* && rm -rf /var/cache/apk/*

ENV GRPC=1.30.0
# compile grpc extension
RUN set -xe \
    && curl -fSL http://pecl.php.net/get/grpc-${GRPC}.tgz -o grpc.tar.gz \
    && mkdir -p /tmp/grpc \
    && tar -xf grpc.tar.gz -C /tmp/grpc --strip-components=1 \
    && rm grpc.tar.gz \
    && docker-php-ext-configure /tmp/grpc --enable-grpc \
    && docker-php-ext-install /tmp/grpc \
    && rm -r /tmp/grpc

ENV PROTOBUF=3.13.0
# compile protobuf extension
RUN set -xe \
    && curl -fSL http://pecl.php.net/get/protobuf-${PROTOBUF}.tgz -o protobuf.tar.gz \
    && mkdir -p /tmp/protobuf \
    && tar -xf protobuf.tar.gz -C /tmp/protobuf --strip-components=1 \
    && rm protobuf.tar.gz \
    && docker-php-ext-configure /tmp/protobuf --enable-protobuf \
    && docker-php-ext-install /tmp/protobuf \
    && rm -r /tmp/protobuf

RUN rm -rf /tmp/* && rm -rf /var/cache/apk/*

RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
    && php composer-setup.php --1 \
   && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer


RUN set -xe \
&& mkdir -p  /var/lib/apt/lists/ && cd /var/lib/apt/lists/ && git clone https://github.com/google/protobuf.git \
&& cd protobuf && git submodule update --init --recursive && sh autogen.sh \
&& ./configure --prefix=/usr/local/ && make && make install && ldconfig

RUN set -xe \
&&cd /usr/local/ && git clone -b v1.37.0 https://github.com/grpc/grpc \
&& cd grpc && git submodule update --init && mkdir -p cmake/build \
&& cd cmake/build && cmake ../.. && make protoc grpc_php_plugin

RUN rm -rf /var/lib/apt/lists/*
