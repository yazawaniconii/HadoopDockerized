FROM hadoop-zk:latest

COPY ./config /tmp/config

RUN set -eu; \
    mkdir -p /data/zookeeper; \
    cp -f /tmp/config/core-site.xml $HADOOP_CONF_DIR/core-site.xml; \
    cp -f /tmp/config/hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml; \
    cp -f /tmp/config/mapred-site.xml $HADOOP_CONF_DIR/mapred-site.xml; \
    cp -f /tmp/config/yarn-site.xml $HADOOP_CONF_DIR/yarn-site.xml; \
    cp -f /tmp/config/zoo.cfg $ZOOKEEPER_HOME/conf/zoo.cfg; \
    cp -f /tmp/config/workers /workers; \
    cp -f /tmp/config/startup.sh /startup.sh; \
    cp -f /tmp/config/node01.sh /node01.sh; \
    cp -f /tmp/config/node02.sh /node02.sh; \
    cp -f /tmp/config/node03.sh /node03.sh; \
    chmod +x /startup.sh /node01.sh /node02.sh /node03.sh; \
    rm -rf /tmp/config
