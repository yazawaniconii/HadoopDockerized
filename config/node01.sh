#!/bin/bash
cd $(dirname $0)

service ssh start

cat /workers > $HADOOP_HOME/etc/hadoop/workers
echo 1 > /data/zookeeper/myid

zkServer.sh start

hdfs --daemon start journalnode

# namenode conf: file:/path/to/namenode
NAMENODE_CONF=$(hdfs getconf -confKey dfs.namenode.name.dir)
NAMENODE_DIR=${NAMENODE_CONF:5}

if [ "$(ls -A ${NAMENODE_DIR})" != "" ]; then
    echo "namenode's not empty"
else
    hdfs namenode -format
    hdfs --daemon start namenode
fi

echo '*starting historyserver*'
mapred --daemon start historyserver
echo '*done*'

function cleanup()
{
    echo '*stopping historyserver*'
    mapred --daemon stop historyserver
    echo '*stopping zookeeper*'
    zkServer.sh stop
    echo '*stopping ssh*'
    service ssh stop
    echo '*done*'
    exit
}
trap cleanup SIGHUP SIGINT SIGQUIT SIGTERM

read