#!/bin/bash
cd $(dirname $0)

service ssh start

cat /workers > $HADOOP_HOME/etc/hadoop/workers
echo 3 > /data/zookeeper/myid

zkServer.sh start

hdfs --daemon start journalnode

function cleanup()
{
    echo '*stopping zookeeper*'
    zkServer.sh stop
    echo '*stopping ssh*'
    service ssh stop
    echo '*done*'
    exit
}
trap cleanup SIGHUP SIGINT SIGQUIT SIGTERM

read