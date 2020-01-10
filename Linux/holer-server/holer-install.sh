#!/bin/bash

# Copyright 2018-present, Yudong (Dom) Wang
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------------------
# Holer Installation Script
# -----------------------------------------------------------------------------
cd `dirname $0`

SYSD_DIR="/lib/systemd/system"
RCD_DIR="/etc/rc.d/init.d"
INITD_DIR="/etc/init.d"
BIN_DIR="/usr/bin"

DOMAIN="@DOMAIN@"
DBUSER="@DBUSER@"
DBPASSWD="@DBPASSWD@"
NGINX_HOME="@NGINX_HOME@"
LICENSE="@LICENSE@"

INSTALL_NAME=$0
INSTALL_OPTIONS="$@"
INSTALL_OPTION_NUM=$#

HOLER_OK=0
HOLER_ERR=1

HOLER_DOMAIN=""
HOLER_DBUSER="root"
HOLER_DBPASSWD=""
HOLER_NGINX_HOME=""
HOLER_LICENSE=""

HOLER_NGINX_CONF_DIR="conf"
HOLER_NGINX_CONF=$HOLER_NGINX_CONF_DIR/nginx.conf

HOLER_CUR_DIR=`pwd`
HOLER_NAME=holer
HOLER_LINUX=$HOLER_NAME-linux
HOLER_SERVER=$HOLER_NAME-server

HOLER_HOME_DIR=/opt/$HOLER_NAME
HOLER_SERVER_DIR=$HOLER_HOME_DIR/$HOLER_SERVER
HOLER_LOG_DIR=$HOLER_SERVER_DIR/logs
HOLER_BIN_DIR=$HOLER_SERVER_DIR/bin
HOLER_CONF_DIR=$HOLER_SERVER_DIR/resources

HOLER_PACK=$HOLER_CUR_DIR/$HOLER_LINUX.tar.gz
HOLER_LOG=$HOLER_LOG_DIR/$HOLER_SERVER.log
HOLER_CONF=$HOLER_CONF_DIR/application.yaml
HOLER_BIN=$HOLER_BIN_DIR/$HOLER_NAME

HOLER_PROGRAM=$BIN_DIR/$HOLER_NAME
HOLER_SERVICE=$HOLER_NAME.service

holer_input() 
{
    if [ -z "$HOLER_DBUSER" ]; then
        echo "Enter database user name, or press Enter to use root by default:"
        read HOLER_DBUSER
        if [ -z "$HOLER_DBUSER" ]; then
            HOLER_DBUSER="root"
        fi
    fi

    if [ -z "$HOLER_DBPASSWD" ]; then
        echo "Enter database password, or press Enter for no password:"
        read HOLER_DBPASSWD
    fi

    if [ "$HOLER_DBUSER" != "" ]; then
        echo "INFO: Ensure the database is accessible with the account '$HOLER_DBUSER/$HOLER_DBPASSWD'."
    fi

    if [ -z "$HOLER_NGINX_HOME" ]; then
        while :
        do
            echo "Enter nginx home, or press Enter to use IP without nginx:"
            read HOLER_NGINX_HOME
            if [ -z "$HOLER_NGINX_HOME" ]; then
                break
            elif [ ! -d "$HOLER_NGINX_HOME" ]; then
                echo "ERROR: The nginx home directory does not exist."
            elif [ ! -f "$HOLER_NGINX_HOME/$HOLER_NGINX_CONF" ]; then
                echo "ERROR: The 'nginx.conf' is missing from the '$HOLER_NGINX_HOME/$HOLER_NGINX_CONF_DIR' directory."
                echo "Ensure the nginx home directory is correct and the 'nginx.conf' exists."
            else
                break
            fi
        done
    fi

    if [ -z "$HOLER_DOMAIN" ]; then
        echo "Enter domain name, or press Enter to use IP and port:"
        read HOLER_DOMAIN
        if [ "$HOLER_DOMAIN" != "" ]; then
            ping -c 3 $HOLER_DOMAIN
            if [ $? -ne 0 ]; then
                echo "WARN: Ensure the domain resolution of '$HOLER_DOMAIN' is available."
            fi
        fi
    fi

    if [ -z "$HOLER_LICENSE" ]; then
        echo "Enter license number, or press Enter to support one port mapping by default:"
        read HOLER_LICENSE
    fi
}

holer_init()
{
    if [ ! -d $HOLER_LOG_DIR ]; then
        mkdir -p $HOLER_LOG_DIR
    fi

    if [ -f $HOLER_PROGRAM ]; then
        sh $HOLER_PROGRAM stop > /dev/null 2>&1
    fi

    tar -zxvf $HOLER_PACK -C $HOLER_HOME_DIR/ >> $HOLER_LOG 2>&1
    cp $HOLER_BIN $BIN_DIR/

    chmod +x $HOLER_BIN
    chmod +x $HOLER_BIN_DIR/*.sh
    chmod +x $HOLER_PROGRAM

    # Update holer configuration
    sed -i "s#${DBUSER}#${HOLER_DBUSER}#g" $HOLER_CONF
    sed -i "s#${DBPASSWD}#${HOLER_DBPASSWD}#g" $HOLER_CONF
    sed -i "s#${NGINX_HOME}#${HOLER_NGINX_HOME}#g" $HOLER_CONF
    sed -i "s#${DOMAIN}#${HOLER_DOMAIN}#g" $HOLER_CONF
    sed -i "s#${LICENSE}#${HOLER_LICENSE}#g" $HOLER_CONF

    # Install Java
    which java >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        return $HOLER_OK
    fi

    which yum >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        echo "Installing java..."
        yum -y install java >> $HOLER_LOG 2>&1
        echo "Done"
    fi

    which apt >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        echo "Installing java..."
        apt -y install openjdk-8-jre >> $HOLER_LOG 2>&1
        echo "Done"
    fi

    return $HOLER_OK
}

setup_sysd()
{
    if [ -d $SYSD_DIR ]; then
        cp $HOLER_BIN_DIR/$HOLER_SERVICE $SYSD_DIR/
        chmod 644 $SYSD_DIR/$HOLER_SERVICE
    fi

    which systemctl >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        systemctl enable $HOLER_SERVICE
        systemctl daemon-reload
        systemctl start $HOLER_SERVICE
        systemctl status $HOLER_SERVICE
    fi

    return $HOLER_OK
}

setup_initd()
{
    if [ -d $RCD_DIR ]; then
        cp $HOLER_PROGRAM $RCD_DIR/$HOLER_SERVICE
        chmod +x $RCD_DIR/$HOLER_SERVICE
    fi

    if [ -d $INITD_DIR ]; then
        cp $HOLER_PROGRAM $INITD_DIR/$HOLER_SERVICE
        cp $HOLER_PROGRAM $INITD_DIR/$HOLER_NAME.sh
        chmod +x $INITD_DIR/$HOLER_SERVICE
        chmod +x $INITD_DIR/$HOLER_NAME.sh
    fi

    which chkconfig >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        chkconfig --add $HOLER_SERVICE
        chkconfig $HOLER_SERVICE on
        chkconfig --list |grep $HOLER_SERVICE >> $HOLER_LOG 2>&1
    fi

    which update-rc.d >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        update-rc.d $HOLER_SERVICE defaults
        update-rc.d $HOLER_NAME.sh defaults
    fi

    which service >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        service $HOLER_NAME start >> $HOLER_LOG 2>&1
    fi

    return $HOLER_OK
}

holer_setup()
{
    setup_sysd >> $HOLER_LOG 2>&1
    setup_initd >> $HOLER_LOG 2>&1

    if [ -f $HOLER_PROGRAM ]; then
        sh $HOLER_PROGRAM start
    fi
}

holer_usage()
{

cat << HOLER_USAGE
    *************************************************************
    Usage   : 
    sh ${INSTALL_NAME} -u DB_USER -p DB_PASSWD \ \n
       -n NGINX_HOME -d DOMAIN -l LICENSE
    -------------------------------------------------------------
    Example :
    sh ${INSTALL_NAME} -u root -p 12345 -n /usr/local/nginx \ \n
       -d mydomain.com -l a0b1c2d3e4f5g6h7i8j9k
    *************************************************************
HOLER_USAGE

}

holer_option()
{
    if [  $INSTALL_OPTION_NUM -lt 1 ]; then
        return $HOLER_OK
    fi

    while [ $# -ge 1 ]; do
        case $1 in
            -u )
                export HOLER_DBUSER=$2
                if [ $# -lt 2 ]; then 
                    break
                fi
                shift 2
                ;;
            -p )
                export HOLER_DBPASSWD=$2
                if [ $# -lt 2 ]; then 
                    break
                fi
                shift 2
                ;;
            -n )
                export HOLER_NGINX_HOME=$2
                if [ $# -lt 2 ]; then 
                    break
                fi
                shift 2
                ;;
            -d )
                export HOLER_DOMAIN=$2
                if [ $# -lt 2 ]; then 
                    break
                fi
                shift 2
                ;;
            -l )
                export HOLER_LICENSE=$2
                if [ $# -lt 2 ]; then 
                    break
                fi
                shift 2
                ;;
            -h )
                holer_usage
                exit $HOLER_OK
                ;;
            * )
                if [ $# -lt 1 ]; then 
                    break
                fi
                shift
                ;;
        esac
    done
}

holer_install()
{
    HOLER_LINE_NUM=324
    tail -n +$HOLER_LINE_NUM $0 > $HOLER_PACK

    holer_option $INSTALL_OPTIONS
    holer_input

    echo "Installing holer..."

    holer_init
    holer_setup

    echo "Done."
    exit $HOLER_OK
}

holer_install
