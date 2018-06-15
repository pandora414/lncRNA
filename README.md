# lncRNA

#### 项目介绍
nextflow pipeline for lncRNA

#### 软件架构
The pipeline is built using Nextflow, a bioinformatics workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It comes with docker / singularity containers making installation trivial and results highly reproducible.


#### 安装教程

1. 安装jdk-1.8 
2. 安装Nextflow
3. 安装Docker
4. 安装Anaconda2

操作系统要求：centos7 

yum install java-1.8.0-openjdk wget

wget -qO- https://get.nextflow.io | bash

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

1. Run Test

> nextflow run dggene/lncRNA

2. xxxx
3. xxxx

#### 参与贡献

1. Fork 本项目
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request


#### 码云特技

1. 使用 Readme\_XXX.md 来支持不同的语言，例如 Readme\_en.md, Readme\_zh.md
2. 码云官方博客 [blog.gitee.com](https://blog.gitee.com)
3. 你可以 [https://gitee.com/explore](https://gitee.com/explore) 这个地址来了解码云上的优秀开源项目
4. [GVP](https://gitee.com/gvp) 全称是码云最有价值开源项目，是码云综合评定出的优秀开源项目
5. 码云官方提供的使用手册 [http://git.mydoc.io/](http://git.mydoc.io/)
6. 码云封面人物是一档用来展示码云会员风采的栏目 [https://gitee.com/gitee-stars/](https://gitee.com/gitee-stars/)