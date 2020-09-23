PHP-ZendServer
==============
This is a cluster-enabled version of a Dockerized Zend Server container.
With Zend Server on Docker, you'll get your PHP applications up and running on a highly available PHP production environment which includes, amongst other features, a highly reliable PHP stack, application monitoring, troubleshooting, and the new and innovative new technology - Z-Ray. Z-Ray gives developers unprecedented visibility into their code by tracking and displaying in a toolbar live and detailed info on how the various elements constructing their page are performing.

For development purposes we provide you with a time limited trial license. For production use you must provide a valid Zend Server license using the instructions below in the Usage section.

Usage
-----
#### Launching the Container from Docker-Hub
Zend Server is shared on [Docker-Hub] as **php-zendserver**.
- To start a single Zend Server instance, execute:

        $ docker run php-zendserver

- You can specify the Zend Server version by adding ':<php-version>'  to the 'docker run' command. Availible Zend Server versions are: 
	- 2019.0 (PHP 7.1, 7.2 and 7.3) 
	- 9.1 (PHP 7.1)
	- 8.5 (PHP 5.6)

  For example: php-zendserver:2019.0.

- To start a Zend Server cluster, execute the following command for each cluster node:

        $ docker run -e MYSQL_HOSTNAME=<db-ip> -e MYSQL_PORT=3306 -e MYSQL_USERNAME=<username> -e MYSQL_PASSWORD=<password> -e MYSQL_DBNAME=zend php-zendserver
- To use your own Zend Server license
        $ docker run php-zendserver -e ZEND_LICENSE_KEY=<license-key> -e ZEND_LICENSE_ORDER=<order-number>

#### Specifying License details

- **`ZS_LICENSE_KEY`** and
- **`ZS_ORDER_NUMBER`** can be used to apply your existing Zend Server license to the Docker containers that you start. Otherwise you'll be using a short temporary license included with the image.
```
docker run --rm -Pti \
    -e ZS_LICENSE_KEY=1A2B3C4D5E6F7G8H9I0J9K8L7M6N5O4P  \
    -e ZS_ORDER_NUMBER=102030 \
php-zendserver bash
```

#### Specifying custom password for UI
- **`ZS_ADMIN_PASSWORD`** can be used to set an 'admin' password for Zend Server UI. If this variable is not specified, a password will be generated and displayed in container's standard output. Therefore, especially if you're running the container in detached mode, your only way of finding out the password is reading the logs:
```
docker run --rm -Pd php-zendserver| xargs docker logs -f
```
or setting `$ZS_ADMIN_PASSWORD` to a value that you won't forget
```
docker run --rm -Pd -e ZS_ADMIN_PASSWORD="your-custom-password" php-zendserver
```

#### Accessing Zend server
Once started, the container will output the information required to access the PHP application and the Zend Server UI, including an automatically generated admin password.

To access the container **remotely**, port forwarding must be configured, either manually or using docker.
For example, this command redirects port 80 to port 88, and port 10081 (Zend Server UI port) to port 10088:

        $ docker run -p 88:80 -p 10088:10081 php-zendserver

#### Setting up cluster

- **`ZS_CLUSTER="TRUE"`** can be set to instruct the initialization script to add the server to a cluster, connection to which is defined by the next 2 variables:
  - **`ZS_DB_HOST`** defines the database host for the database 'ZendServer'. Can be a host name or IP address - either way, it will be converted to an IP address. Custom ports (not 3306) are not supported.
  - **`MYSQL_ROOT_PASSWORD`** the database connection user is always 'root' and it is assumed that this user always needs a password.
```
docker run --rm -Pti \
    -e ZS_CLUSTER="TRUE" \
    -e ZS_DB_HOST="maria.db.local" \
    -e MYSQL_ROOT_PASSWORD="your-mysql-root-password" \
php-zendserver bash
```

Please note, that when running multiple instances only one instance can be bound to a port.
If you are running a cluster, either assign a port redirect to one node only, or assign a different port to each container.

#### Pre init and Post init scripts

- **`ZS_PRE_INIT="/full/path/to/program"`** and
- **`ZS_POST_INIT="/full/path/to/program"`** can be specified to be run, respectively, before or/and after the intitialization routines. In most cases you would mount a directory or just the script into the container and use these variables to execute it.
```
docker run --rm -Pti \
    -v /my/local/updater.sh:/usr/local/bin/upd.sh \
    -e ZS_PRE_INIT=/usr/local/bin/upd.sh \
php-zendserver bash
```

### Minimal Requirements

- Each Zend Server Docker container requires 1GB of availible memory.

[Docker-Hub]:https://registry.hub.docker.com/_/php-zendserver/
