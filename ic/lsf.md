
# lsf

[IBM官方文档(直接搜索lsf命令)](https://www.ibm.com/docs/en)

[IBM官方文档中文版(机翻)](https://www.ibm.com/docs/zh)

[安装openlava](https://www.cnblogs.com/alittlemc/p/16646098.html)

LSF（Load Sharing Facility）采用了RPC（Remote Procedure Call）机制来实现任务调度和管理等功能。具体来说，LSF使用了一种基于RPC的通信协议，称为LSF RPC Protocol。

在LSF中，各个组件之间可以通过RPC进行通信和交互，比如集群节点和集中调度服务器之间的通信。LSF RPC Protocol使用了TCP/IP作为传输层协议，并使用二进制数据格式进行编码和解码。它定义了一系列标准的RPC接口和协议规范，用于实现任务提交、资源分配、作业状态查询等操作。

通过LSF RPC Protocol，LSF能够快速、高效地处理大量的作业和任务，并提供了丰富的调度和管理功能，例如动态资源分配、负载均衡和故障恢复等。因此，LSF已被广泛应用于科学计算、工程设计以及云计算等领域。

## 注意事项

* job 超过一定时间(一般1小时)就会在内存中被清除，通过 bjobs \<jobid\> 方式查询不到(显示为not found)，在 lsb.events 日志中最终状态为 JOB_CLEAN

## 进阶使用方法

<https://zhuanlan.zhihu.com/p/426515062>

```text
作业的管理：如何查看作业的详细信息以及管理作业的行为状态
作业行为定制：如何进行前处理和后处理，如何自动处理作业的异常状况
作业资源需求声明：如何写作业对资源的需求，包括NUMA节点和GPU的指定方法
一般的使用技巧：如何使用选项模版提交作业，如何快速提交批量作业，如何定制命令行输出格式等
使用管理员定义的对象：如何查看和使用队列， 应用配置以及预留资源
```

## 命令

### 提交任务

```sh
bsub [-q <queue>] [-m <host>] [-o <log>] [-e <err.log>] [-cwd <working_directory>] <EXE>
-Ip: 在当前shell交互
# 引用jobid: %J
```

### 查看任务

```sh
bjobs [<JOBID> <JOBID2> ...]
-u: 指定用户，all 表示所有用户
-w: 显示完整shell命令，默认精简显示
-l: 显示指定任务细节信息，输出有多行
-W: 显示资源占用情况
-p: 显示 pending 任务及原因
-r: 显示正在运行任务
-s: 显示暂停任务及原因
-d: 显示最近结束任务
-a: 显示所有状态的任务，包括最近结束的
-m: 指定host
-aps: 查看任务优先级，指定 APS 才有
-env: 查看指定任务提交时环境变量
-noheader: 不显示表头
-script: 显示指定任务提交时的脚本
```

```sh
# 终止指定任务
bkill <JOBID> [<JOBID2> ...]
# 终止当前用户所有任务
bkill 0

# 查看所有队列
bqueues
# 查看指定用户可以使用的队列
bqueues -u <user_id>

# 查看所有主机
bhosts

# 查看指定队列关联主机
bhosts <queue>

# 查看负载
lsload [HOST_NAME]

# 查看任务在各个状态持续时间
bhist
bhist -l <JOBID>
```

### IBM lsf log

```sh
# 记录任务状态日志路径
tail -f $INSTALL/logdir/lsb.events

# 记录任务结束状态日志路径
tail -f $INSTALL/logdir/lsb.acct
```
