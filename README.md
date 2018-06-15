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

    channels:
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/
      - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
      - defaults
    show_channel_urls: true


#### 使用说明

1. Run


    nextflow run dggene/lncRNA --data-file=xxxx/data.ini

Example data.ini

    [sample]
    HL=HL.left.fq.gz|HL.right.fq.gz
    
    [group]
    group1=sample1,sample2
    group2=sample2,sample3
  
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
