#!/bin/bash

sleep 1

if [ -d /usr/local/zend/tmp/ini-patches ]; then
	# if the directory exists, we probably want to patch some config files
	/usr/local/bin/paccini.sh
fi

ZEM=$(find /usr/local/zend/etc -iname zend_extension_manager.ini)
mv $ZEM ${ZEM}.BAK

if [ $# -eq 0 ]; then
	cd /lambdas
	/usr/local/zend/bin/php server.php
else
	echo " --- !!! --- Server not started --- !!! ---"
	exec "$@"
fi
