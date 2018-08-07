#!/bin/sh

echo "This script will define the nginx.org repository on your system"
echo "See support matrix at http://nginx.org/en/linux_packages.html#distributions"
echo

if `type lsb_release > /dev/null 2>&1`; then
	CURRENT_OS=`lsb_release -d -s`
elif [ -f /etc/system-release ]; then
	CURRENT_OS=`head -1 /etc/system-release`
elif [ -f /etc/issue ]; then
	CURRENT_OS=`head -1 /etc/issue`
else
	echo "Can't identify your system using lsb_release or /etc/issue in order to"
	echo "configure nginx.org repository."
	exit 1
fi
	
if echo $CURRENT_OS | grep -q "CentOS release 5"; then
	OS=centos
	OSRELEASE=5
	TYPE=rpm
elif echo $CURRENT_OS | grep -q "CentOS release 6"; then
	OS=centos
	OSRELEASE=6
	TYPE=rpm
elif echo $CURRENT_OS | grep -q "CentOS Linux release 7"; then
	OS=centos
	OSRELEASE=7
	TYPE=rpm
elif echo $CURRENT_OS | grep -q "Red Hat Enterprise Linux Server release 5"; then
	OS=rhel
	OSRELEASE=5
	TYPE=rpm
elif echo $CURRENT_OS | grep -q "Red Hat Enterprise Linux Server release 6"; then
	OS=rhel
	OSRELEASE=6
	TYPE=rpm
elif echo $CURRENT_OS | grep -q "Red Hat Enterprise Linux Server release 7"; then
	OS=rhel
	OSRELEASE=7
	TYPE=rpm
elif echo $CURRENT_OS | grep -q "Debian GNU/Linux 6"; then
	OS=debian
	OSRELEASE=squeeze
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Debian GNU/Linux 7"; then
	OS=debian
	OSRELEASE=wheezy
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Debian GNU/Linux 8"; then
	OS=debian
	OSRELEASE=jessie
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 10.04"; then
	OS=ubuntu
	OSRELEASE=lucid
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 11.10"; then
	OS=ubuntu
	OSRELEASE=oneiric
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 12.04"; then
	OS=ubuntu
	OSRELEASE=precise
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 12.10"; then
	OS=ubuntu
	OSRELEASE=quantal
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 13.04"; then
	OS=ubuntu
	OSRELEASE=raring
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 13.10"; then
	OS=ubuntu
	OSRELEASE=saucy
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 14.04"; then
	OS=ubuntu
	OSRELEASE=trusty
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 14.10"; then
	OS=ubuntu
	OSRELEASE=utopic
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 15.04"; then
	OS=ubuntu
	OSRELEASE=vivid
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 15.10"; then
	OS=ubuntu
	OSRELEASE=wily
	TYPE=deb
elif echo $CURRENT_OS | grep -q "Ubuntu 16.04"; then
	OS=ubuntu
	OSRELEASE=xenial
	TYPE=deb
else
	echo "Based on either lsb_release or /etc/issue your OS version is not supported by nginx.org"
	exit 2
fi

MYUID=`id -u 2> /dev/null`
if [ ! -z "$MYUID" ]; then
    if [ $MYUID != 0 ]; then
        echo "You need root privileges to run this script";
        exit 2
    fi
else
    echo "Could not detect UID";
    exit 2
fi

if [ "$TYPE" = "rpm" ]; then
	wget http://nginx.org/keys/nginx_signing.key 2> /dev/null && rpm --import nginx_signing.key; rm -f nginx_signing.key
	SOURCE_REPO_FILE=`dirname $0`/nginx.repo
	TARGET_REPO_FILE=/etc/yum.repos.d/nginx.repo
elif [ "$TYPE" = "deb" ]; then
	wget http://nginx.org/keys/nginx_signing.key -O- 2> /dev/null | apt-key add -
	SOURCE_REPO_FILE=`dirname $0`/nginx.list
	TARGET_REPO_FILE=/etc/apt/sources.list.d/nginx.list
else
	echo "Package manager type not defined, cannot configure repository"
	exit 2
fi

# Set repository 
cp -f $SOURCE_REPO_FILE $TARGET_REPO_FILE && sed "s/OSRELEASE/$OSRELEASE/g" -i $TARGET_REPO_FILE &&  sed "s/OS/$OS/g" -i $TARGET_REPO_FILE
if [ $? = 0 ]; then
	echo
	echo "*** nginx.org repository configured successfully at $TARGET_REPO_FILE ***" 
fi
