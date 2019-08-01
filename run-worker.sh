#!/bin/bash
/opt/spark/sbin/start-slave.sh --host $MY_POD_IP --webui-port $SPARK_WORKER_WEBUI_PORT spark://$SPARK_MASTER_SERVICE_HOST:$SPARK_MASTER_SERVICE_PORT_SPARK
