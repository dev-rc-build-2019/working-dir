#!/bin/bash
#
#################################
orabase='/app/oracle'
orahome="/app/oracle/product/19.0.0/dbhome_1"
oraid=${USER}
srvname=`hostname -a`
port=1531
notifylist="<email>"
ngdbnotify="<sec email>"
###############################
# set default values for sga(2GB) and characterset
###############################
sgasz=2
###############################
# Set values externally
###############################
export ORACLE_BASE=${orabase}
export ORACLE_HOME=${orahome}
export NOTIFY_LIST=${notifylist}
export NOTIFY_NGDB=${ngdbnotify}
###############################
# end of script
























































