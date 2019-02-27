#!/bin/bash

# 测试环境: Ubuntu 14.04.1 Desktop LTS amd64

# 检测是否以root运行.
check_root() 
{
  if [ ! $( id -u ) -eq 0 ]; then
    echo "请使用root权限执行"
    exit -1;
  fi
}

# 在文件中增加一行配置
append2file()
{
    if [ "$#" -ne 2 ]; then
        printf "\n======== 配置参数为空 ========\n"
        exit -1;
    fi

    centent=$1
    file=$2
    # 完整例子: 
    #        grep -qxF 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config || echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" | tee -a /etc/ssh/sshd_config
    grep -qxF "$centent" "$file" || echo "$centent" | tee -a "$file"
}

# 检测是否以root运行
check_root

# openssh的版本, 使用目前最新的7.9版本
VERSION="7.9p1"

# 当前目录
CURRENT_DIR=$(cd "$(dirname "$0")"; pwd)

# 依赖安装：
apt-get install -y libpam0g-dev

# 备份原有配置：
cp /etc/init.d/ssh /etc/init.d/ssh.bak
cp /etc/ssh/ssh_config /etc/ssh/ssh_config.bak
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 安装命令如下：
wget https://openbsd.hk/pub/OpenBSD/OpenSSH/portable/openssh-${VERSION}.tar.gz
tar zxf openssh-${VERSION}.tar.gz
cd openssh-${VERSION}
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-pam
make 
cp opensshd.init /etc/init.d/ssh
cp ssh_config /etc/ssh/ssh_config
cp sshd_config /etc/ssh/sshd_config

# 因配置会影响系统默认的中文编码，因此加下列命令
append2file 'export LANG=zh_CN.UTF-8' /etc/profile 
append2file 'set fileencodings=utf-8,gb2312,gbk,gb18030' /etc/vim/vimrc 
append2file 'set termencoding=utf-8' /etc/vim/vimrc 
append2file 'set encoding=prc' /etc/vim/vimrc

# 在/etc/ssh/sshd_config文件中增加强加密配置
append2file 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr' /etc/ssh/sshd_config 

# 安装
make install

# 删除安装包
rm -rf ${CURRENT_DIR}/openssh-*

# 打印结束信息并退出
sync
printf "\n======== 安装完成 ========\n"
exit 0
