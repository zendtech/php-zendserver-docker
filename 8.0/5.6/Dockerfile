# Zend Server
#
# Version 0.2

FROM ubuntu:14.04

RUN apt-key adv --keyserver pgp.mit.edu --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623
RUN echo "deb http://repos.zend.com/zend-server/8.0/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list
RUN apt-get update && apt-get install -y libmysqlclient18 unzip git zend-server-php-5.6 && /usr/local/zend/bin/zendctl.sh stop

COPY ./zend.lic /etc/

ADD http://repos.zend.com/zs-init/zs-init-docker-0.2.tar.gz .
RUN mkdir /usr/local/zs-init && tar xzf zs-init-docker-0.2.tar.gz --strip-components=1 -C /usr/local/zs-init

WORKDIR /usr/local/zs-init
RUN /usr/local/zend/bin/php -r "readfile('https://getcomposer.org/installer');" | /usr/local/zend/bin/php
RUN /usr/local/zend/bin/php composer.phar update

COPY ./scripts /usr/local/bin
COPY ./Zray /usr/local/zend/var/plugins/

RUN rm /var/www/html/index.html
COPY ./app /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 10081
EXPOSE 10082

CMD ["/usr/local/bin/run"]
