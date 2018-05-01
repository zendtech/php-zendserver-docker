#!/bin/bash

ZEND_SERVER_PATH='/usr/local/zend'
ZSD_FULL_PATH="${ZEND_SERVER_PATH}/bin/zsd"
ZSD_DB_PATH="${ZEND_SERVER_PATH}/var/db/zsd.db"
ZSD_DB_CMD="sqlite3 ${ZSD_DB_PATH}"

echo $ZEND_SERVER_PATH
#Check if any nodes require restart
NODE_IDS_REQUIRING_RESTART=$(${ZSD_DB_CMD} <<EOF 
SELECT NODE_ID FROM ZSD_NODES where STATUS_CODE=3;
EOF
)

#Restart pending nodes
if [ -n "$NODE_IDS_REQUIRING_RESTART" ]
then
echo "Executing pending Zend Server restart operations..."
#TODO: check if ZSD DB is locked
#If so then restart them by inserting tasks into ZSD sqlite db (TODO: replace with proper API)
sqlite3 $ZSD_DB_PATH <<EOF
begin transaction;
with recursive 
 nodes_requiring_restart(node_id) as (SELECT NODE_ID FROM ZSD_NODES where STATUS_CODE=3)
 INSERT INTO ZSD_TASKS (NODE_ID,TASK_ID) VALUES ((SELECT node_id from nodes_requiring_restart),0);
commit;
EOF

fi
