#!/bin/bash
#  check_opatch_ver_19.sh
#    Version:  19c and higher
#    check current OPatch version and replace if not current version
#
# Use the variable below to switch between /data (testing) and /app (prod)
################
export ORAENV=/app/vendor/oracle
export OPATCH_DIR=${ORAENV}/DB/PatchDir/OPatch/19000/OPatch
export ORATAB=/etc/oratab
export ORACLE_HOME=`grep "product/19" $ORATAB |head -1 |awk -F ":" '{print $2}'`
export HOSTNAME=`hostname`
#export DBA_MAIL='renee.j.cutler@lmco.com'
export DBA_MAIL='i2d2.hybrid.database.dl-eit@exch.ems.lmco.com'
#
# Determine the versions 
# Current version - ORACLE_HOME
curver=`$ORACLE_HOME/OPatch/opatch version | awk -F ':' '{print $2}'`
echo "Current OPatch Version " $curver > /tmp/opatch.ver
#
# Latest version - Oracle 
oraver=`$OPATCH_DIR/opatch version | awk -F ':' '{print $2}'`
echo "Oracle latest OPatch Version " $oraver >> /tmp/opatch.ver
#
# check for errors
if [ -z $curver ] || [ -z $oraver ]; then
   echo "Not able to compare versions - check ORACLE_HOME"
   exit 1
else
#
# check versions if current version is not equal to the Oracle version
#   update the current version
  if [ $curver != $oraver ]
  then
    # set date format
    ldate=`date +%F`
    echo "Updating OPatch " >> /tmp/opatch.ver
    cd $ORACLE_HOME
    mv OPatch OPatch.$ldate
    unzip ${ORAENV}/OPatch/p6880880_190000_Linux-x86-64.zip
#
# List current ORACLE_HOME version 
    ohver=`$ORACLE_HOME/OPatch/opatch version | awk -F ':' '{print $2}'`
    echo "Updated ORACLE_HOME OPatch Version " $ohver >> /tmp/opatch.ver
#
# send email on upgrade
    mailx -s "D2 PATCHING -- OPatch version updated on $HOSTNAME " oracle@$HOSTNAME $DBA_MAIL < /tmp/opatch.ver
#
#
# If the version current - send email - no changes
  else
#
# send email - no changes
  mailx -s "D2 PATCHING -- OPatch version current on $HOSTNAME " oracle@$HOSTNAME $DBA_MAIL < /tmp/opatch.ver
#
  fi
fi 
# remove the file
rm -rf /tmp/opatch.ver
