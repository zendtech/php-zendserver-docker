# Zend Server
#
# Version 2018.0.3+b24

FROM ubuntu:16.04

#apt-get is run twice to allow installing gnupg which is required for apt-key

RUN apt-get update \
    && apt-get -y install gnupg wget aptitude apt-utils \
    && wget http://downloads.zend.com/zendserver/2018.0.3/ZendServer-2018.0.3-RepositoryInstaller-linux.tar.gz \
    && tar xf ZendServer-2018.0.3-RepositoryInstaller-linux.tar.gz \
    && cd ZendServer-RepositoryInstaller-linux \
    && ./install_zs.sh 7.2 --automatic \
    && apt-get install -y \
      libmysqlclient20 \
      unzip \
      git \
      curl \
      net-tools \
    && rm -rf /var/lib/apt/lists/* \
    && /usr/local/zend/bin/zendctl.sh stop

#Set default license
COPY ./zend.lic /etc/

#Make apache drop the HTTP_PROXY header to fix CVE-2016-5385, CVE-2016-5387
COPY ./drop-http-proxy-header.conf /etc/apache2/conf-available
RUN  /usr/sbin/a2enconf drop-http-proxy-header \
     && /usr/sbin/a2enmod headers

# "zs-init" is a standard Zend Server cloud initialization package.
# It has minor tweaks for use within Docker which can be found at https://github.com/zendtech/zs-init/treye/docker
ENV ZS_INIT_VERSION 0.3
ENV ZS_INIT_SHA256 e8d441d8503808e9fc0fafc762b2cb80d4a6e68b94fede0fe41efdeac10800cb
RUN curl -fSL -o zs-init.tar.gz "http://repos.zend.com/zs-init/zs-init-docker-${ZS_INIT_VERSION}.tar.gz" \
    && echo "${ZS_INIT_SHA256} *zs-init.tar.gz" | sha256sum -c - \
    && mkdir /usr/local/zs-init \
    && tar xzf zs-init.tar.gz --strip-components=1 -C /usr/local/zs-init \
    && rm zs-init.tar.gz

#Install composer and dependencies for zs-init
WORKDIR /usr/local/zs-init
RUN  /usr/local/zend/bin/php /usr/local/zend/bin/composer.phar self-update && /usr/local/zend/bin/php /usr/local/zend/bin/composer.phar update

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
