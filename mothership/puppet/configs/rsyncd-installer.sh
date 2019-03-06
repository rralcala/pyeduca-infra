#!/bin/bash

DAEMON_ORIG="/etc/xinetd.d/xs-rsyncd"
CONF_ORIG="/etc/xs-rsyncd.conf"
DAEMON_PYEDU="/usr/local/backup/xs-rsyncd"
CONF_PYEDU="/usr/local/backup/xs-rsyncd.conf"

grep -q "\= root" $DAEMON_ORIG; 

if [[ $? != 0 ]]; then
	cp $DAEMON_PYEDU $DAEMON_ORIG;
	service xinetd restart;
fi

grep -q "^\[users\]" $CONF_ORIG; 

if [[ $? != 0 ]]; then
	cp $CONF_PYEDU $CONF_ORIG;
	service xinetd restart;
fi
