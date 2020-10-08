#!/bin/bash

# re: metalog.log - OK messages should not normally be displayed
#                   in container's STDOUT, saving for cluster mode

sleep 2

# shortcuts for most frequent operations in Bash
cat >> /root/.bashrc <<EOP
alias l='ls -alF --color=auto --group-directories-first'
alias ll='ls -alF --color=auto --group-directories-first'
alias zs='/usr/local/zend/bin/zendctl.sh'
alias zsr='ps -eo pid,user,command|grep -E "[z]end|[a]pache|[h]ttpd|[n]ginx"|sed "s/^\s*//"|cut -d" " -f1|xargs kill -9;sleep 1;ps faux;/usr/local/zend/bin/zendctl.sh start'
alias zcd='cd /usr/local/zend'
ZS=/usr/local/zend
TERM=xterm

# double-check for interactive shell
if grep i <<< \$- > /dev/null 2>&1; then zsinfo; fi

EOP


if [ -d /usr/local/zend/tmp/ini-patches ]; then
	# if the directory exists, we probably want to patch some config files
	/usr/local/bin/paccini.sh
fi

if [[ -n $ZS_PRE_INIT ]]; then
	echo "Will try to run $ZS_PRE_INIT"
	if [ -f "$ZS_PRE_INIT" ]; then
		# making sure that we don't fail on a simple permission issue
		chmod +x "$ZS_PRE_INIT"
		bash -c "$ZS_PRE_INIT"
	fi
fi

# Pre-launch initialization of Zend Server
. /etc/zce.rc
$ZCE_PREFIX/bin/zsd $ZCE_PREFIX/etc/zsd.ini -e $(openssl enc -base64 -d -A <<< LS1nZW5lcmF0ZS1saWNlbnNl) > /tmp/metalog.log 2>&1


if [[ -n $ZS_ORDER_NUMBER ]]; then
	cat <<EOST > /root/checLic.php
<?php
\$o = "$ZS_ORDER_NUMBER"; \$k = "$ZS_LICENSE_KEY"; \$a=zem_serial_number_info(\$k, \$o);
echo "Order #: \$o   ||  License Key: \$k\n";
if (\$a['license_ok']) {
echo "The license is VALID\n------------------------------\n";
\$b = \$a['edition'];
if ( \$b==2 || \$b==7 || \$b==6 || \$b==8 || \$b==3 ) {
echo "Expires - " . date('j F Y', \$a['expiration_date']) . "\nServers - {\$a['num_of_nodes']}\n------------------------------\n"; exit(0);
} else { fwrite(STDERR, "Zend Server edition not recognised. Probably INVALID license.\n\n"); exit(1); }
} else { fwrite(STDERR, "This license is INVALID.\n\n"); exit(1); }
EOST

	/usr/local/zend/bin/php -f /root/checLic.php >> /tmp/metalog.log

	if [ $? -ne 0 ]; then
		echo "License not changed, will try to continue anyway" > /dev/stderr
	else
		ZGD=$(find /usr/local/zend/etc -iname ZendGlobalDirectives.ini)
		# in ZS 2019.0.0 the table names changed
		tableName=$(echo -e "2018.99.99\n$PRODUCT_VERSION" | sort -V | head -1 | sed 's|2018\.99\.99|zsd_zend_common_directives|' | sed "s|^[0-9].*$|zsd_directives|")
		sed -i -e "s|^\s*zend.serial_number.*\$|zend.serial_number=$ZS_LICENSE_KEY|" -e "s|^\s*zend.user_name.*\$|zend.user_name=$ZS_ORDER_NUMBER|" $ZGD
		sqlite3 /usr/local/zend/var/db/zsd.db "UPDATE $tableName SET DISK_VALUE='$ZS_LICENSE_KEY' WHERE NAME = 'zend.serial_number'; UPDATE $tableName SET DISK_VALUE='$ZS_ORDER_NUMBER' WHERE NAME = 'zend.user_name';"
	fi
	rm -f /root/checLic.php
fi

bash -c "/usr/local/zend/bin/zendctl.sh start" > /dev/null 2>&1

if [ -z $ZS_ADMIN_PASSWORD ]; then
	ZS_ADMIN_PASSWORD="$(openssl rand -base64 12)"
fi

echo "Zend Server GUI Password (for user 'admin'): $ZS_ADMIN_PASSWORD" >> /tmp/metalog.log
/usr/local/zend/bin/php /usr/local/zend/bin/gui_passwd.php "$ZS_ADMIN_PASSWORD" >> /tmp/metalog.log


# generating a random WebAPI key for 'docker' 
WEB_API_SECRET="$(tr -cd '0-9a-f' < /dev/urandom | fold -w64 | head -1)"
sqlite3 /usr/local/zend/var/db/gui.db "update GUI_WEBAPI_KEYS set HASH='$WEB_API_SECRET' where NAME = 'docker';"

# if it's the first server, these will be used for the entire cluster
if [ ! -s /var/zs-xchange/web_api_secret ]; then
	echo $WEB_API_SECRET > /var/zs-xchange/web_api_secret
	echo "$ZS_ADMIN_PASSWORD" > /var/zs-xchange/ui_admin_pw
fi

if [ "$ZS_CLUSTER" == "TRUE" ] && [ "$ZS_DB_HOST$MYSQL_ROOT_PASSWORD" != "" ]; then

	# license check and change information will be helpful in cluster (compose), outputting now
	cat /tmp/metalog.log
	rm -f /tmp/metalog.log

	mkdir /var/zs-xchange/$HOSTNAME
	NODE_IP=$(dig $HOSTNAME +short)
	DB_IP=$(dig $ZS_DB_HOST +short)
	echo "nodeIP=$NODE_IP" > /var/zs-xchange/$HOSTNAME/ip.txt

	echo "Joining Zend Server cluster (DB @ $DB_IP) as $HOSTNAME ($NODE_IP)"

	/usr/local/zend/bin/zs-manage server-add-to-cluster -T 120 -n $HOSTNAME -i $NODE_IP -o $DB_IP -u root -p $MYSQL_ROOT_PASSWORD -d ZendServer -N docker -K $WEB_API_SECRET -s | sed 's| ||g' > /var/zs-xchange/$HOSTNAME/id.txt
	# e.g.:
	#  NODE_ID=4
	#  WEB_API_KEY=docker
	#  WEB_API_KEY_HASH=200fd7eeb56b5f0061cb4e1b009f0d7f2ca94ecfc4ba035a6e1dac368914b2a9
	. /var/zs-xchange/$HOSTNAME/id.txt
	export NODE_ID

	echo

	# I really hate doing this, but without this restart ZS 2019.0 seems to be in trouble
	echo "Final restart of Zend Server ......  "
	bash -c "/usr/local/zend/bin/zendctl.sh start" > /dev/null 2>&1
	echo "[done]"
fi

if [[ -n $ZS_POST_INIT ]]; then
	echo "Will try to run $ZS_POST_INIT"
	if [ -f "$ZS_POST_INIT" ]; then
		# making sure that we don't fail on a simple permission issue
		chmod +x "$ZS_POST_INIT"
		bash -c "$ZS_POST_INIT"
	fi
fi

if [ $# -eq 0 ]; then
	exec nodeWatch
else
	exec "$@"
fi
