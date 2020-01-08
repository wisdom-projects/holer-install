# Holer Install

Holer安装包主要功能包括：安装软件、启动服务、设置开机自启动服务以及软件卸载等。

执行holer安装包程序，可以一键式完成软件安装，参数配置，服务启动，服务开机自启动等工作。

## 1. 安装holer

### 1.1 软件安装包

下载 **holer-install.xxx**

[地址一](https://github.com/wisdom-projects/holer-install/releases)

[地址二](https://pan.baidu.com/s/1APDAaaaQxTa71IR2hDjIaA#list/path=%2Fsharelink2808252679-1014620033513253%2Fholer%2Fholer-client%2Finstall&parentPath=%2Fsharelink2808252679-1014620033513253)

### 1.2 使用方法
`sh holer-install.xxx -k HOLER_ACCESS_KEY -s HOLER_SERVER_HOST`

### 1.3 使用示例
`sh holer-install.x86 -k a0b1c2d3e4f5g6h7i8j9k -s holer.org`

## 2. 卸载holer
执行命令：
`sh holer-uninstall.sh`

## 3. 注意事项
目前holer的安装与卸载仅支持**Linux系统**，使用前执行命令`uname -m`查看硬件架构，选择跟自己硬件架构匹配的安装包。

也可以直接使用安装包`holer-install.bin`，该安装包支持所有主流的Linux硬件架构。

