#!/bin/bash

if [ "$ZS_CLUSTER" = "TRUE" ]; then
	# We can't really enable Session Clustering without a cluster.
	# Assuming that ZS_CLUSTER=TRUE worked and we are in cluster.

	source /var/zs-xchange/$HOSTNAME/id.txt
	WEB_API_SECRET="$(cat /var/zs-xchange/web_api_secret)"

	if [ "$NODE_ID" = "1" ]; then
		# We only do this once per cluster, node 1 is the logical choice.
		# Assuming that the extension is enabled, turn on Session Clustering.
		/usr/local/zend/bin/zs-manage store-directive -d 'session.save_handler' -v 'cluster' -N docker -K $WEB_API_SECRET
		/usr/local/zend/bin/zs-manage restart -N docker -K $WEB_API_SECRET
	else
		# All other nodes seem to need an additional restart after joining
		# the cluster and enabling Session Clustering.
		# ('else' is here only for the purpose of adding this explanation)
		/usr/local/zend/bin/zs-manage restart -N docker -K $WEB_API_SECRET
	fi
fi
