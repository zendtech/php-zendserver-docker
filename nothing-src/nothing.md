# Overview #

nothing is a simple daemon that was written to deal with remove of Zend Server
nodes when CloudFoundry instance is stopped or restarted.

When instance on CloudFoundry is taken down all it's processes are sent
SIGTERM signal. There is no hook in CloudFoundry itself for instance going
down. Additionally instances do not know anything about each other. Therefore
when instance is going down it is not deregistered from Zend Server Cluster.

To fix this issue __nothing__ daemon was written in C and it works as following:

1. If no parameters were specified, then daemon simply runs until some signal
   kills it. When it is killed nothing happens (it just exits).
2. If MySQL and Zend Server details are specified in parameters, then daemon
   works as following. On startup zend\_cf\_remove\_servers table is created in
   MySQL DB. This table has only one column - ID. It is used to store IDs of
   nodes that must be removed from Zend Server Cluster. Later SIGTERM signal
   handler registered and all it does is just store current Zend Server node ID
   in that table and close connection. Additionally every second
   zend\_cf\_remove\_servers is checked and if new entry exists in it,
   ```zs-manage``` is called to remove cluster node.

# Compilation and installation #

To compile nothing you will need a maching running Ubunut 10.04 64-bit. Install
necessary packages on it:

```
aptitude update
aptitude install libmysqlclient-dev build-essential
```

After that copy all files in that directory to server. Enter the directory and
run in it:

```
make
```

This will compile nothing binary. After compiling it, copy it into your git repo
and commit changes.

# Running nothing and it's parameters #

nothing has following parameters:

```
./nothing <mysql-hostname> <mysql-port> <mysql-username> <mysql-password> <mysql-db-name> <server-id> <web-api-key-name> <web-api-key>
```

There are 2 options to run nothing:

1. Run it without parameters. In that case all it does almost nothing. It just
   sleeps and waits to be killed.
2. Supply all the parameters. In this case it will monitor
   zend\_cf\_remove\_servers table and insert it's own node ID in it on SIGTERM
   signal.
