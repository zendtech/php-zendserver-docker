php-ZendServer
==============

This is a cluster enabled version of a Dockerized Zend Server 7.0.0 container.
From a local folder containing this repo's clone, execute ` docker build . ` to generate the image. the image id will be outputted.
Afterwards, start a ZS clustered container be executing:

<span>`docker run -p 10088:10081 -e MYSQL_HOSTNAME=<db-ip> -e MYSQL_PORT=3306 -e MYSQL_USERNAME=<username> -e MYSQL_PASSWORD=<password> -e MYSQL_DBNAME=zend <image-id>`</span>

Zend Server UI will be available at http://localhost:10088 .
To add additional nodes to the cluster execute the same command, ommitting the port forward ("-p 10088:10081", as it is already in use).

