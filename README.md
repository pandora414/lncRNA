# lncRNA

#### 项目介绍
nextflow pipeline for lncRNA

#### 软件架构
该流程使用Nextflow开发，主要用于lncRNA分析。

nextflow 是一个生物信息流程搭建工具，具有原生支持多并发、支持docker、conda，解决了生物信息分析中最麻烦的软件环境部署问题。



#### 安装教程

1. 安装jdk-1.8 
2. 安装Nextflow
3. 安装Docker
4. 安装Anaconda2

操作系统要求：centos7 

yum install java-1.8.0-openjdk wget

wget -qO- https://get.nextflow.io | bash

nextflow 学习文档 https://www.nextflow.io/docs/latest/getstarted.html

#### Docker依赖
##### Docker安装
> curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
##### 配置docker国内加速器
    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
    {
    "registry-mirrors": ["https://rppkjtdx.mirror.aliyuncs.com"]
    }
    EOF
    systemctl daemon-reload
    systemctl restart docker
    
##### Anaconda2

    wget -qO - https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda2-5.2.0-Linux-x86_64.sh|bash

在安装目录下：/opt/anaconda2 新建 .condarc ,填入如下内容

由于r包的安装主要依赖bioconda，所以bioconda和conda-forge的源需要放在最前面，不然会报缺少库文件的错误

    channels:
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
      - defaults
    show_channel_urls: true

####配置数据库
    
    此流程依赖两个数据库目录：hg19和kobas
    两个数据库默认位置分别为：
    /DG/database/genomes/Homo_sapiens/hg19
    /DG/database/pub/KOBAS/
    可以通过 命令行参数或者创建同目录名的软连接方式。




####配置ldap，本地测试可省略，主要用于集群运行

    yum install -y nss-pam* 
    authconfig-tui

    
    ┌────────────────┤ Authentication Configuration ├─────────────────┐
    │                                                                 │
    │  User Information        Authentication                         │
    │  [*] Cache Information   [*] Use MD5 Passwords                  │
    │  [*] Use LDAP            [*] Use Shadow Passwords               │
    │  [ ] Use NIS             [*] Use LDAP Authentication            │
    │  [ ] Use IPAv2           [ ] Use Kerberos                       │
    │  [ ] Use Winbind         [ ] Use Fingerprint reader             │
    │                          [ ] Use Winbind Authentication         │
    │                          [*] Local authorization is sufficient  │
    │                                                                 │
    │            ┌────────┐                      ┌──────┐             │
    │            │ Cancel │                      │ Next │             │
    │            └────────┘                      └──────┘             │
    │                                                                 │
    │                                                                 │
    └─────────────────────────────────────────────────────────────────┘

    Server: ldap://172.16.0.210_
    Base DN: dc=dg,dc=com

####安装pbs mom  本地测试可省略，主要用于集群运行
    echo /usr/local/lib > /etc/ld.so.conf.d/local.conf
    ldconfig
    sh torque-package-mom-linux-x86_64.sh
    echo node210.DG > /var/spool/torque/server_name
    cp /DG/programs/stable/src/torque-4.2.6.1/contrib/init.d/pbs_mom /etc/init.d
    systemctl enable pbs_mom
    systemctl restart pbs_mom



#### 使用说明

1. Run

    测试运行，可以直接执行：
    nextflow run dggene/lncRNA

    本地运行需要提供data.ini配置文件
    nextflow run dggene/lncRNA --data-file=xxxx/data.ini

    带数据库参数方式运行：
    nextflow run dggene/lncRNA --data-file=xxxx/data.ini --database={hg19数据库路径} --database_kobas={kobas数据库路径}

Example data.ini

    [sample]
    HL = HL.left.fq.gz|HL.right.fq.gz
    HL_1 = HL_1.left.fq.gz|HL_1.right.fq.gz

    [group]
    group1 = HL,HL_1
  
数据配置文件为标准的ini格式，其中sample分组表示需要分析的样本信息，格式为 name=path1|path2,name为样本名称，path为样本路径
，路径可以是绝对路径也可以相对路径，如果是相对路径，则是相对于data.ini文件的路径

2. 流程更新

    当对流程做了更新以后，需要通知生信人员及时更新本地克隆的分支，方式如下：
    
    
    nextflow pull dggene/lncRNA
    

3. xxxx

#### 参与贡献

1. Fork 本项目
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

#### 参考资料
biocontainer 常见的生物信息镜像
https://biocontainers.pro/registry/#/

bio.tools 收集了常见的生物信息分析软件，提供在线文档
https://bio.tools

docker 提供软件运行的环境，可以把每个软件打包为镜像，每个镜像可以理解为一个个集装箱，那么搭建一个分析流程的过程就是装配这些集装箱的过程 
https://www.docker.com/

anaconda 原本是提供一个python的发行版本，内含了大量的科学运算包，可以快速进行软件的安装
https://anaconda.org/