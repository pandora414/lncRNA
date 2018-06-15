安装依赖库
yum install -y nfs-util nss-pam* bzip2

修改hostname
hostnamectl set-hostname xxxx.DG

加入到openldap中

    authconfig-tui
    ldap://172.16.0.210/
    dc=dg,dc=com

挂载本地nas磁盘

    172.16.0.51:/home         /DG/home/       nfs4     defaults  0       0
    172.16.0.51:/data1        /DG/project0    nfs4     defaults  0       0
    172.16.0.51:/rawdata      /DG/rawdata     nfs4     defaults  0       0
    172.16.0.51:/project1     /DG/project1    nfs4     defaults  0       0
    172.16.0.51:/programs   /DG/programs    nfs4    defaults        0       0
    172.16.0.51:/database2 /DG/database     nfs4    defaults        0       0

安装pbs mom 

1. 添加内网dns服务器，172.16.0.210
2. /DG/programs/stable/src/torque-4.2.6.1/torque-package-mom-linux-x86_64.sh --install
3. 修改/var/spool/torque/server_name      node210

安装docker

安装anaconda2

wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/archive/Anaconda2-5.2.0-Linux-x86_64.sh
sh Anaconda2-5.2.0-Linux-x86_64.sh -p /opt/anaconda2


