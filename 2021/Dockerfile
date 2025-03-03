# Zend Server
#
# Version 2021.4.1+b12

FROM ubuntu:20.04

RUN apt-get update && apt-get install -y --no-install-recommends \
      gnupg

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623
COPY zend-server.list /etc/apt/sources.list.d/zend-server.list
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update && apt-get install -y --no-install-recommends \
      iproute2 \
      curl \
      ca-certificates \
      libmysqlclient21 \
      unzip \
      git \
      patch \
      zend-server-nginx=2021.4.1+b12 \
      zend-server-common=2021.4.1+b12 \
      php-extra-extensions-zend-server \
      php-ffi-zend-server \
    && rm -rf /var/lib/apt/lists/* \
    && /usr/local/zend/bin/zendctl.sh stop

# "zs-init" is a standard Zend Server cloud initialization package.
# It has minor tweaks for use within Docker which can be found at https://github.com/zendtech/zs-init/tree/docker
ENV ZS_INIT_VERSION=0.3
ENV ZS_INIT_SHA256=e8d441d8503808e9fc0fafc762b2cb80d4a6e68b94fede0fe41efdeac10800cb
COPY ./zs-init.patch /tmp/zs-init.patch
RUN curl -fSL -o zs-init.tar.gz "http://repos.zend.com/zs-init/zs-init-docker-${ZS_INIT_VERSION}.tar.gz" \
    && echo "${ZS_INIT_SHA256} *zs-init.tar.gz" | sha256sum -c - \
    && mkdir /usr/local/zs-init \
    && tar xzf zs-init.tar.gz --strip-components=1 -C /usr/local/zs-init \
    && rm zs-init.tar.gz \
    && patch -u /usr/local/zs-init/src/Init/Steps/AbstractStep.php -i /tmp/zs-init.patch \
    && rm /tmp/zs-init.patch

#Install composer and dependencies for zs-init
WORKDIR /usr/local/zs-init
RUN /usr/local/zend/bin/php -r "readfile('https://getcomposer.org/installer');" | /usr/local/zend/bin/php \
    && /usr/local/zend/bin/php composer.phar update

COPY ./scripts /usr/local/bin 
#Copy Zray docker plugin
#TODO: Integrate Zray docker plugin into Zend Server
COPY ./Zray /usr/local/zend/var/plugins/

RUN rm /var/www/html/index.nginx-debian.html
COPY ./app /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 10081
EXPOSE 10082

WORKDIR /var/www/html

CMD ["/usr/local/bin/run"]
