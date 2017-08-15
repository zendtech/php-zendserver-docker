# Zend Server
#
# Version 9.0.1

FROM ubuntu:14.04

RUN apt-get update && apt-get install -y curl && curl http://repos.zend.com/zend.key | apt-key add -
RUN echo "deb http://repos.zend.com/zend-server/9.0/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list
RUN apt-get update && apt-get install -y libmysqlclient18 unzip git zend-server-nginx-php-7.0 && /usr/local/zend/bin/zendctl.sh stop 

COPY ./zend.lic /etc/

# "zs-init" is a standard Zend Server cloud initialization package.
# It has minor tweaks for use within Docker which can be found at https://github.com/zendtech/zs-init/tree/docker
ENV ZS_INIT_VERSION 0.3
ENV ZS_INIT_SHA256 1c5cf557daf48cf018dba1cf46208f215d3b5fab47c73ff2d39988581ebd6932
RUN curl -fSL -o zs-init.tar.gz "http://repos.zend.com/zs-init/zs-init-docker-${ZS_INIT_VERSION}.tar.gz" \
    && echo "${ZS_INIT_SHA256} *zs-init.tar.gz" | sha256sum -c - \
    && mkdir /usr/local/zs-init \
    && tar xzf zs-init.tar.gz --strip-components=1 -C /usr/local/zs-init \
    && rm zs-init.tar.gz

WORKDIR /usr/local/zs-init
RUN /usr/local/zend/bin/php -r "readfile('https://getcomposer.org/installer');" | /usr/local/zend/bin/php
RUN /usr/local/zend/bin/php composer.phar update

COPY ./scripts /usr/local/bin
COPY ./Zray /usr/local/zend/var/plugins/

EXPOSE 80
EXPOSE 443
EXPOSE 10081
EXPOSE 10082

WORKDIR /usr/share/nginx/html

CMD ["/usr/local/bin/run"]
