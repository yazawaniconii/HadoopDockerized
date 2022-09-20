# Docker 搭建基础 Hadoop 集群 

## 构建镜像

构建镜像的 dockerfile 放在 `dockerfiles` 目录下，`hadoop-base` 只包含了最基础的 Hadoop 环境，`hadoop-zk` 基于 `hadoop-base` 并包含了 Zookeeper 环境。根项目下的 `dockerfile` 是 compose 的时候用的，将预先写好的配置文件打包到镜像。可以使用类似命令构建 `hadoop-base` 和 `hadoop-zk` ：

```bash
docker build -t hadoop-base -f hadoop-base .
docker build -t hadoop-zk -f hadoop-zk .
```

## 启动容器

可以用以下命令启动容器：

```bash
docker-compose up -d --build
```

停止容器：

```bash
docker-compose stop
```

删除容器：

```bash
docker-compose down --rmi local
```

## 一些细节

docker 在 `stop` 的时候只会向 PID 1 的进程发送 TERM 信号，若超时后该进程还未结束，docker 就会向容器发送 KILL 信号。为了优雅地结束容器和避免[僵尸进程问题](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/)，则 PID 1 进程需要处理信号，我在该项目中使用一个脚本作为 init 进程并处理信号，相关代码为：

```bash
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
```

在运行各项命令后，脚本执行完成进程结束则容器结束。
