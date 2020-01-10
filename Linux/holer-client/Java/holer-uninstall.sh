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
# Holer Uninstallation Script
# -----------------------------------------------------------------------------
cd `dirname $0`

SYSD_DIR="/lib/systemd/system"
RCD_DIR="/etc/rc.d/init.d"
INITD_DIR="/etc/init.d"
BIN_DIR="/usr/bin"

HOLER_OK=0
HOLER_ERR=1

HOLER_NAME=holer
HOLER_CLIENT=$HOLER_NAME-client

HOLER_HOME_DIR=/opt/$HOLER_NAME
HOLER_CLIENT_DIR=$HOLER_HOME_DIR/$HOLER_CLIENT
HOLER_BIN_DIR=$HOLER_CLIENT_DIR/bin
HOLER_LIB_DIR=$HOLER_CLIENT_DIR/lib
HOLER_CONF_DIR=$HOLER_CLIENT_DIR/conf
HOLER_LOG_DIR=$HOLER_CLIENT_DIR/logs
HOLER_LOG=$HOLER_LOG_DIR/$HOLER_CLIENT.log

HOLER_PROGRAM=$BIN_DIR/$HOLER_NAME
HOLER_SERVICE=$HOLER_NAME.service

unset_sysd()
{
    which systemctl >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        systemctl stop $HOLER_SERVICE
        systemctl disable $HOLER_SERVICE
        systemctl daemon-reload
    fi

    if [ -f $SYSD_DIR/$HOLER_SERVICE ]; then
        rm -f $SYSD_DIR/$HOLER_SERVICE
    fi

    return $HOLER_OK
}

unset_initd()
{
    which service >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        service $HOLER_NAME stop
    fi

    which chkconfig >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        chkconfig $HOLER_SERVICE off
        chkconfig --del $HOLER_SERVICE
    fi

    which update-rc.d >> $HOLER_LOG 2>&1
    if [ $? -eq 0 ]; then
        update-rc.d -f $HOLER_SERVICE remove
        update-rc.d -f $HOLER_NAME.sh remove
    fi

    if [ -f $RCD_DIR/$HOLER_SERVICE ]; then
        rm -f $RCD_DIR/$HOLER_SERVICE
    fi

    if [ -f $INITD_DIR/$HOLER_SERVICE ]; then
        rm -f $INITD_DIR/$HOLER_SERVICE
    fi

    if [ -f $INITD_DIR/$HOLER_NAME.sh ]; then
        rm -f $INITD_DIR/$HOLER_NAME.sh
    fi

    return $HOLER_OK
}

holer_unset()
{
    if [ -f $HOLER_PROGRAM ]; then
        sh $HOLER_PROGRAM stop
    fi
    unset_sysd >> $HOLER_LOG 2>&1
    unset_initd >> $HOLER_LOG 2>&1
}

holer_remove()
{
    if [ -f $HOLER_PROGRAM ]; then
        rm -f $HOLER_PROGRAM
    fi

    if [ -d $HOLER_CLIENT_DIR ]; then
        rm -rf $HOLER_LIB_DIR
        rm -rf $HOLER_CONF_DIR
        rm -rf $HOLER_CLIENT_DIR/*.jar
    fi
}

holer_uninstall()
{
    echo "Uninstalling holer..."
    holer_unset
    holer_remove
    echo "Done."
    exit $HOLER_OK
}

holer_uninstall
