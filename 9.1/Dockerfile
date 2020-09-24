FROM ubuntu:xenial

ARG zs_build=b202
ARG zs_flavor=nginx
ARG zs_ver=9.1.10
ARG zs_php=7.1
ARG image=ubuntu
ARG tag=xenial

EXPOSE 80 443 10081 10082

RUN bash -c 'apt-get update && apt-get -y install curl wget sqlite3 nano net-tools gnupg && apt-get clean'
COPY ZS /root/files/
RUN  mv /root/files/ZSinstall.sh /root/ && chmod 775 /root/ZSinstall.sh && sleep 1

RUN /root/ZSinstall.sh $zs_ver $zs_php $zs_flavor $image $tag $zs_build

RUN rm /var/www/html/index.nginx-debian.html
COPY app/index.php /var/www/html/
# Another Example: /root/ZSinstall.sh 2018.0 7.2 apache-fpm debian stretch

#        debian squeeze          6
#               wheezy           7
#               jessie           8
#               stretch          9
#        ubuntu precise          12.04
#               trusty           14.04
#               xenial           16.04
#               bionic           18.04

ENTRYPOINT ["/usr/local/bin/run.sh"]
