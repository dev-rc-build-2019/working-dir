#!/bin/ksh
#
############
#orabase=${ORACLE_BASE}
#orahome=${ORACLE_HOME}
############
#  CHANGE AS NEEDED
############
orabase='/app/oracle'
orahome='/app/oracle/product/19.0.0/dbhome_1'
oraid=${USER}
srvname=`hostname -a`
port=1531
notifylist="renee.j.cutler@lmco.com,i2d2.hybrid.database.dl-eit@exch.ems.lmco.com"
ngdbnotify="vincent.salerno@lmco.com"
############
# set default values for sga(2GB) and characterset
############
sgasz=2
############
# Set values externally
#setenv ORACLE_BASE $orabase
#setenv ORACLE_HOME $orahome
############
export ORACLE_BASE=$orabase
export ORACLE_HOME=$orahome
export NOTIFY_LIST=$notifylist
export NOTIFY_NGDB=$ngdbnotify
