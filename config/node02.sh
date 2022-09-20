#!/bin/bash
cd $(dirname $0)

service ssh start

cat /workers > $HADOOP_HOME/etc/hadoop/workers
echo 2 > /data/zookeeper/myid

zkServer.sh start

hdfs --daemon start journalnode

# namenode conf: file:/path/to/namenode
NAMENODE_CONF=$(hdfs getconf -confKey dfs.namenode.name.dir)
NAMENODE_DIR=${NAMENODE_CONF:5}

if [ "$(ls -A ${NAMENODE_DIR})" != "" ]; then
    echo "namenode's not empty"
else
    sleep 5
    hdfs namenode -bootstrapStandby
    hdfs zkfc -formatZK
fi

$HADOOP_HOME/sbin/start-all.sh

function cleanup()
{
    echo '*stopping all*'
    $HADOOP_HOME/sbin/stop-all.sh
    echo '*stopping journalnode*'
    hdfs --daemon stop journalnode
    echo '*stopping zookeeper*'
    zkServer.sh stop
    echo '*stopping ssh*'
    service ssh stop
    echo '*done*'
    exit
}
trap cleanup SIGHUP SIGINT SIGQUIT SIGTERM

read