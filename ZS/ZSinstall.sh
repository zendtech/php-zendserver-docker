#!/bin/bash

# This install script makes it easier to create exotic installations of Zend Server
# For Example: ./ZSinstall.sh 9.1.6 7.1 nginx ubuntu bionic
# Another Example: ./ZSinstall.sh 2018.0 7.2 apache-fpm debian stretch
# See also Dockerfile.custom in repository root

#        debian squeeze          6
#               wheezy           7
#               jessie           8
#               stretch          9
#        ubuntu precise          12.04
#               trusty           14.04
#               xenial           16.04
#               bionic           18.04


LOG_FILE=/tmp/install_zs.log

ZS=$1
PHP=$2
WEBSRV=$3
OS=$4
OSRELEASE=$5

OSfull="$OS $OSRELEASE"
# only Ubuntu and Debian are supported
if [ "$OSfull" = "debian squeeze" ]; then
	# debian 6 squeeze, doesn't seem to be on Docker Hub any longer
	REPO="deb"
elif echo "$OSfull" | grep -qE "debian 9|debian stretch"; then
	REPO="deb_debian9"
elif echo "$OSfull" | grep -qE "debian 7|debian wheezy|ubuntu precise|ubuntu quantal|ubuntu raring|ubuntu 12"; then
	REPO="deb_ssl1.0"
elif echo "$OSfull" | grep -qE "ubuntu bionic|ubuntu 18"; then
	REPO="deb_ssl1.1"
else
	# debian 8 (jessie), ubuntu 14-16
	REPO="deb_apache2.4"
fi

# ZS 2019.0.0 (and up?) needs to be installed with new meta-packages, e.g.:
# old: zend-server-nginx-php-7.1 zend-server-php-7.1-common
# new: zend-server-nginx zend-server-common
packageSuffix=$(echo -e "2018.99.99\n$ZS" | sort -V | head -1 | sed 's|2018\.99\.99||' | sed "s|^[0-9].*\$|-php-$PHP|")

# Apache + mod_php is not a great idea for Docker, hence no support for this
if [ "$WEBSRV" = "nginx" ]; then
	WHAT_TO_INSTALL="zend-server-nginx$packageSuffix"
elif [ "$WEBSRV" = "apache-fpm" ]; then
	WHAT_TO_INSTALL="zend-server-apache-fpm$packageSuffix"
fi
WHAT_TO_INSTALL="$WHAT_TO_INSTALL zend-server$packageSuffix-common"

echo "Top packages for installation: $WHAT_TO_INSTALL" >> $LOG_FILE



if [ "$WEBSRV" = "nginx" ]; then
	lowest=$(echo -e "9.0\n$ZS" | sort -Vr | head -1)
	if [ "$lowest" = "9.0" ]; then
		# wget -qO - https://nginx.org/keys/nginx_signing.key | apt-key add -
		apt-key adv --keyserver keyserver.ubuntu.com --recv-key ABF5BD827BD9BF62
		SOURCE_REPO="deb http://nginx.org/packages/OS/ OSRELEASE nginx"
		TARGET_REPO_FILE=/etc/apt/sources.list.d/nginx.list
	else
		TARGET_REPO_FILE=/dev/null
	fi

	# Set repository
	echo "$SOURCE_REPO" | sed -e "s/OSRELEASE/$OSRELEASE/g" -e "s/OS/$OS/g" > $TARGET_REPO_FILE
	if [ $? != 0 ]; then
		echo
		echo "*** nginx.org repository configuration failed ***"
		exit 1
	fi
fi


REPO_URL="http://repos.zend.com/zend-server/$ZS/$REPO"

# Set repository
echo "deb $REPO_URL server non-free" > /etc/apt/sources.list.d/zend.list
# wget -qO - https://repos.zend.com/zend.key | apt-key add -
apt-key adv --keyserver keyserver.ubuntu.com --recv-key 799058698E65316A2E7A4FF42EAE1437F7D2C623
apt-get update

# Define a fuction to verify deb packages, as we need to verify
# each in a loop instead all at once (JIRA issue ZSRV-15762)
verify_deb() {
		VERIFY_RC=0
		# shellcheck disable=SC2048
		for package in $*; do
				dpkg-query -W -f='${Status}\n' $package | grep -q ' installed'
				RC=$?
				if [ $RC -gt 0 ]; then
						echo "Package $package is not installed."
						VERIFY_RC=$RC;
				fi
		done
		return $VERIFY_RC
}

RC=0

echo "Executing: apt-get -y install $WHAT_TO_INSTALL" >> $LOG_FILE
apt-get -y install adduser
apt-get -y install $WHAT_TO_INSTALL
RC=$?
echo "Exit code: $RC" >> $LOG_FILE
verify_deb $WHAT_TO_INSTALL 2> /dev/null
VERIFY_RC=$?
rm -rf /var/lib/apt/lists/*



if [ $RC -eq 0 ] && [ $VERIFY_RC -eq 0 ]; then
	if [ "$WEBSRV" = "apache-fpm" ]; then
		a2enmod ssl && a2ensite default-ssl
		rm -f /root/files/default_nginx_ssl.conf
	elif [ "$WEBSRV" = "nginx" ]; then
		mv /root/files/default_nginx_ssl.conf /etc/nginx/conf.d/
		mkdir /etc/nginx/localhost_certs
		openssl genrsa -out /etc/nginx/localhost_certs/localhost.key 2048
		openssl req -new -x509 -key /etc/nginx/localhost_certs/localhost.key -out /etc/nginx/localhost_certs/localhost.cert -days 3650 -subj /CN=localhost
		chgrp zend /etc/nginx/localhost_certs/localhost.key
		chmod 640 /etc/nginx/localhost_certs/localhost.key
	fi
	bash -c "/usr/local/zend/bin/zendctl.sh restart"
	echo
	echo "*********************************************"
	echo "* Zend Server was successfully installed.   *"
	echo "*********************************************"
else
	echo
	echo "************************************************************************************************"
	echo "* Zend Server Installation was not completed. See output above for detailed error information. *"
	echo "************************************************************************************************"
	exit 1
fi
echo

mv -f $LOG_FILE /tmp/install_zs.log.$$
echo "Log file is kept at /tmp/install_zs.log.$$"

# no worries, this key changes to a more random one during the container startup
WEB_API_SECRET=abfcf1870171fd206240f2e2b5291105c204d5aa65ef57d3fc4fa1ec06bfb445

echo "Setting Docker API key and bootstrapping Zend Server"
/usr/local/zend/bin/zs-manage api-keys-add-key -n docker -s $WEB_API_SECRET
/usr/local/zend/bin/zs-manage bootstrap-single-server -p DUMMY_PASSWORD -a 'TRUE' -t 3 -w 5
/usr/local/zend/bin/zs-manage restart -N docker -K $WEB_API_SECRET

bash -c "/usr/local/zend/bin/zendctl.sh stop"


# cleaning tables, to force rebuilding of blueprint on startup
# not all of these need to be cleaned, but we'll just go certain
isNew=$(echo -e "2018.99.99\n$ZS" | sort -V | head -1 | sed 's|2018\.99\.99|yes|')
if [ "$isNew" == "yes" ]; then
	sqlite3 /usr/local/zend/var/db/zsd.db \
		"delete from ZSD_DIRECTIVES; \
		delete from ZSD_EXTENSIONS; \
		delete from ZSD_PHP_EXTENSIONS; \
		delete from ZSD_PHP_EXTENSIONS_DIRECTIVES; \
		delete from ZSD_ZEND_COMMON_DIRECTIVES; \
		delete from ZSD_ZEND_DAEMONS_DIRECTIVES; \
		delete from ZSD_ZEND_EXTENSIONS; \
		delete from ZSD_ZEND_EXTENSIONS_DIRECTIVES;"
else
	sqlite3 /usr/local/zend/var/db/zsd.db "delete from ZSD_DIRECTIVES; delete from ZSD_EXTENSIONS;"
fi
sqlite3 /usr/local/zend/var/db/gui.db "delete from GUI_WEBAPI_KEYS where NAME = 'admin';"
ZGD=$(find /usr/local/zend/etc -iname ZendGlobalDirectives.ini)
sed -i -e "s|^\s*zend.serial_number.*\$|zend.serial_number=|" -e "s|^\s*zend.user_name.*\$|zend.user_name=|" $ZGD
echo > /usr/local/zend/var/log/zsd.log

ln -s /var/www/html /dr

mv /root/files/* /usr/local/bin/
wget -O /usr/local/bin/zs-client.phar "https://github.com/zend-patterns/ZendServerSDK/raw/master/bin/zs-client.phar"
chmod +x /usr/local/bin/*
mkdir /var/zs-xchange

if [ $VERIFY_RC -ne 0 ]; then
	exit $VERIFY_RC
else
	exit $RC
fi
