# Zend Server
#
# Version 0.2

# TODO:

FROM ubuntu:14.04

RUN apt-key adv --keyserver pgp.mit.edu --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623
RUN echo "deb http://repos.zend.com/zend-server/8.0/deb_apache2.4 server non-free" >> /etc/apt/sources.list.d/zend-server.list
RUN apt-get update && apt-get install -y git zend-server-php-5.6 && /usr/local/zend/bin/zendctl.sh stop
#RUN apt-get update && apt-get install -y git zend-server-php-5.6 

COPY ./zend.lic /etc/

RUN  git clone     https://github.com/dintel/zs-init.git /usr/local/zs-init
WORKDIR /usr/local/zs-init
RUN /usr/local/zend/bin/php -r "readfile('https://getcomposer.org/installer');" | /usr/local/zend/bin/php
RUN /usr/local/zend/bin/php composer.phar update

RUN sed -i '1s/;//' /usr/local/zend/etc/conf.d/pcntl.ini

COPY ./scripts /usr/local/bin
COPY ./libmysqlclient.so.18 /usr/lib/x86_64-linux-gnu/
COPY ./Zray /usr/local/zend/var/zray/extensions/

#RUN rm /var/www/html/index.html
#COPY ./app /var/www/html

EXPOSE 80
EXPOSE 443
EXPOSE 10081
EXPOSE 10082

#ENV zend {"ZEND_ADMIN_PASSWORD":"123456"}

CMD ["/usr/local/bin/run"]
#CMD ["/usr/local/zs-init/init.php"]
#CMD ["/usr/local/zs-init/nothing.php", "/usr/local/bin/nothing"]
