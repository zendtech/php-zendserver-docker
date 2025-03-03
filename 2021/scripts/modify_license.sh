#!/bin/bash
#modify_license.sh - generate /etc/zend.lic to allow overriding the default license in the docker container.

#Environment variables:
#ZEND_LICENSE_ORDER=Order number
#ZEND_LICENSE_KEY=Serial number

#Check if the ZEND_LICENSE_ORDER and ZEND_LICENSE_KEY environment variables are set
if (env | grep -q ^ZEND_LICENSE_ORDER= && env | grep -q ^ZEND_LICENSE_KEY=)
then
  #Generate zend.lic into a temporary location
   echo \{\"ZEND_LICENSE_ORDER\":\"${ZEND_LICENSE_ORDER}\",\"ZEND_LICENSE_KEY\":\"$ZEND_LICENSE_KEY\"\} > /tmp/zend.lic && \
   #move and backup existing zend.lic to /etc
   mv -b /tmp/zend.lic /etc
fi

#always exit with status 0 to not interfere with docker container creation
exit 0
