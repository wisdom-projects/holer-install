# Holer Install

执行holer安装包程序，即可完成软件安装，参数配置，服务启动，服务开机自启动等工作。

## 1. 安装holer

### 1.1 软件安装包

下载 **holer-install.xxx**

[地址一](https://github.com/wisdom-projects/holer-install/releases)

[地址二](https://pan.baidu.com/s/1APDAaaaQxTa71IR2hDjIaA#list/path=%2Fsharelink2808252679-1014620033513253%2Fholer%2Fholer-client%2Finstall&parentPath=%2Fsharelink2808252679-1014620033513253)

### 1.2 使用方法

#### 1.2.1 Holer客户端
执行命令： `sh holer-install.xxx -k HOLER_ACCESS_KEY -s HOLER_SERVER_HOST`

使用示例：
`sh holer-install.x86 -k a0b1c2d3e4f5g6h7i8j9k -s holer.org`

#### 1.2.2 Holer服务端
执行命令：
```
sh holer-install.server -u DB_USER -p DB_PASSWD \
   -n NGINX_HOME -d DOMAIN -l LICENSE
```

使用示例：
```
sh holer-install.server -u root -p 12345 -n /usr/local/nginx \
   -d mydomain.com -l a0b1c2d3e4f5g6h7i8j9k
```

或者执行命令 `sh holer-install.server`，根据提示输入相应的参数，使用示例：
```
sh holer-install.server
Enter database user name, or press Enter to use root by default:
root

Enter database password, or press Enter for no password:

Enter nginx home, or press Enter to use IP for no nginx:
/usr/local/nginx

Enter domain name, or press Enter to use IP and port instead of domain:
holer.org

Enter license number, or press Enter to support one port mapping by default:

Installing holer...
Holer server PID <10635> is running.
Done.
```

## 2. 启停holer
启动holer：
`service holer start`

重启holer：
`service holer restart`

停止holer：
`service holer stop`

查看holer：
`service holer status`

**ARM Linux平台**执行如下命令：

`sh /usr/bin/holer start`

`sh /usr/bin/holer restart`

`sh /usr/bin/holer stop`

`sh /usr/bin/holer status`

## 3. 卸载holer
执行命令：

`sh holer-uninstall.sh`

**注意事项：**

Java版本的holer卸载脚本路径：

`sh /opt/holer/holer-client/bin/holer-uninstall.sh`

## 4. 注意事项
目前holer的安装与卸载仅支持**Linux系统**，使用前执行命令`uname -m`查看硬件架构，选择跟自己硬件架构匹配的安装包。

或者可以直接使用安装包`holer-install.bin`，该安装包支持所有主流的Linux硬件架构。

用户也可以根据偏好选择Java版本的安装包`holer-install.jre`，该安装包支持跨平台。

**Holer服务端软件**安装包`holer-install.server`，该安装包支持跨平台。

