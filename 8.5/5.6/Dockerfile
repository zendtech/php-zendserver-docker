# Zend Server
#
# Version 8.5.20+b34

FROM ubuntu:16.04

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623
COPY zs8_5-apache2_4.list /etc/apt/sources.list.d/zend-server.list
COPY ubuntu-trusty.list /etc/apt/sources.list.d/ubuntu-trusty.list
RUN apt-get update \
    && apt-get install -y \
        curl \
        libmysqlclient18 \
        unzip \
        git \
        zend-server-php-5.6=8.5.20+b34 \
    && rm -rf /var/lib/apt/lists/* \
    && /usr/local/zend/bin/zendctl.sh stop

#Make apache drop the HTTP_PROXY header to fix CVE-2016-5385, CVE-2016-5387
COPY ./drop-http-proxy-header.conf /etc/apache2/conf-available
RUN  /usr/sbin/a2enconf drop-http-proxy-header
RUN  /usr/sbin/a2enmod headers

# "zs-init" is a standard Zend Server cloud initialization package.
# It has minor tweaks for use within Docker which can be found at https://github.com/zendtech/zs-init/tree/docker
ENV ZS_INIT_VERSION=0.3
ENV ZS_INIT_SHA256=e8d441d8503808e9fc0fafc762b2cb80d4a6e68b94fede0fe41efdeac10800cb
RUN curl -fSL -o zs-init.tar.gz "http://repos.zend.com/zs-init/zs-init-docker-${ZS_INIT_VERSION}.tar.gz" \
    && echo "${ZS_INIT_SHA256} *zs-init.tar.gz" | sha256sum -c - \
    && mkdir /usr/local/zs-init \
    && tar xzf zs-init.tar.gz --strip-components=1 -C /usr/local/zs-init \
    && rm zs-init.tar.gz

#Install composer and dependencies for zs-init
WORKDIR /usr/local/zs-init
RUN /usr/local/zend/bin/php -r "readfile('https://getcomposer.org/installer');" | /usr/local/zend/bin/php \
    && /usr/local/zend/bin/php composer.phar self-update && /usr/local/zend/bin/php composer.phar update

COPY ./scripts /usr/local/bin
#Copy Zray docker plugin
#TODO: Integrate Zray docker plugin into Zend Server
COPY ./Zray /usr/local/zend/var/plugins/

RUN rm /var/www/html/index.html
COPY ./app /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 10081
EXPOSE 10082

WORKDIR /var/www/html

CMD ["/usr/local/bin/run"]
