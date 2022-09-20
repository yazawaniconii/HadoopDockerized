#!/bin/bash
cd $(dirname $0)

hdfs --daemon start journalnode
$HADOOP_HOME/sbin/start-dfs.sh
#mapred --daemon start historyserver

function cleanup()
{
    echo '*stopping all*'
    $HADOOP_HOME/sbin/stop-all.sh
    echo '*stopping historyserver*'
    mapred --daemon stop historyserver
    echo 'done'
    hdfs --daemon stop journalnode
    zkServer.sh stop
    service ssh stop
    exit
}
trap cleanup SIGHUP SIGINT SIGQUIT SIGTERM

read
